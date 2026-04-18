local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 }, 6)

-- forward compatible tests with locked properties
game.start_stack = 50000
game.num_players_needed_to_start = 4
game.small_blind = 50
game.double_blind_interval_minutes = 15
game.buy_in = 10

game:join_table(0)
game:join_table(1) -- btn
t.assert_eq(true, game:add_bot()) -- sb
t.assert_eq(true, game:add_bot()) -- bb

-- the bots get pretty high client ids
-- because there are a bunch of fake humans connected
t.assert_eq(48, game.players[3].client_id)
t.assert_eq(49, game.players[4].client_id)

-- auto start with 4 players
t.fake_server_ticks(game, 20)
t.assert_eq(GameState.PRE_FLOP, game.state)

t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 48, "🂵🃅")
t.set_hole_cards(game, 49, "🃋🃛")

t.assert_eq(50, game.small_blind)

t.assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(48).position.offset)
t.assert_eq(49950, game:find_player(48).chips)

-- doing 15 minutes of fake ticks would be too slow so we do a faster time hack
ddnetpp.ticks_passed = ddnetpp.server.tick_speed() * 60 * game.double_blind_interval_minutes + 10
t.fake_server_ticks(game, 10)

t.assert_eq("Blinds up! Small blind is 100 and big blind is 200", ddnetpp.get_chat_line(0, -1))
t.all_check_call_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")

t.assert_eq("You won the entire pot with 400 chips in it!", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))

-- button moved now client id 3 is the small blind
-- and now the new blinds kicked in
-- because this table spent over 15 minutes on the first hand pre flop lmao
t.assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(49).position.offset)

-- start stack is 50000
-- mock3 was big blind in the first round which was 100 (lost first round)
-- and is now small blind in this round which is again 100
-- because the blinds doubled last round
-- so 50000 - 100 - 100 = 49800
t.assert_eq(49800, game:find_player(49).chips)

-- mock0 won the first pot which was just one small blind from everyone
-- all just check called with a big blind of 100 and 4 players that is 400
-- now mock0 is the big blind after the big blind increased to 200
-- so mock0 now has a stack of 50100 which is 100 more than the start stack
-- that is because winning from first round were 300 (because mock0 paid 100 of the 400 pot)
-- minus the now placed big blind of 200
t.assert_eq(50100, game:find_player(0).chips)


-- FIXME: uncomment this as soon as we can let players disconnect during their turn without crash

-- -- let the humans disconnect
-- game:leave_table(0)
-- ddnetpp.players[0] = nil
-- t.fake_server_ticks(game, 1)
-- 
-- game:leave_table(1)
-- ddnetpp.players[1] = nil
-- t.fake_server_ticks(game, 1)
