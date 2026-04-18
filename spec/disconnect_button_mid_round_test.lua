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
game:join_table(2) -- sb
game:join_table(3) -- bb

-- auto start with 4 players
t.fake_server_ticks(game, 20)
t.assert_eq(GameState.PRE_FLOP, game.state)

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })

-- button is next to act
t.assert_eq(1, game:next_to_act().client_id)

-- simulate button disconnect
game:leave_table(1)
ddnetpp.players[1] = nil
t.fake_server_ticks(game, 1)

-- the player that just left the table can no
-- longer be next to act otherwise the game gets stuck
-- because nobody can act anymore
t.assert_ne(1, game:next_to_act().client_id)

-- TODO: not super sure if client id 2 is the correct choice
t.assert_eq(2, game:next_to_act().client_id)

game:player_action(2, { action = "call" })
t.assert_eq("'mock2' called", ddnetpp.get_chat_line(2, -1))

t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })

t.assert_eq(GameState.FLOP, game.state)

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })
t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

t.assert_eq(GameState.TURN, game.state)

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })
t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

t.assert_eq(GameState.RIVER, game.state)
t.assert_eq(4, #game.players) -- 3 active and one player that left mid hand

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })
t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

t.assert_eq(GameState.SHOWDOWN, game.state)
t.all_show(game)
t.next_showdown_card(game)
t.assert_eq(GameState.PRE_FLOP, game.state)

-- now the client id 1 that left got fully removed from the table
t.assert_eq(3, #game.players)

-- button moved to client id 2
t.assert_eq(true, game:find_player(2).is_button)
