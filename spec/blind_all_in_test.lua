local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb

-- big blind only has 10 chips left
-- which is less than the big blind
game:find_player(3).chips = 10

game:new_game()

t.assert_eq(50000, game:find_player(0).chips)
t.assert_eq(50000, game:find_player(1).chips)
t.assert_eq(49950, game:find_player(2).chips)
t.assert_eq(0, game:find_player(3).chips) -- forced all in by blind

-- small blind is 50 so big blind is 100
-- so total pot on round start is expected to
-- be 150 but the big blind is broke and only has 10
-- so the pot is only small blind plus 10
-- which is 60
t.assert_eq(50, game.small_blind)
t.assert_eq(60, game.pot)

t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")

game:player_action(0, { action = "call" })
game:player_action(1, { action = "call" })
t.assert_eq(GameState.PRE_FLOP, game.state)
game:player_action(2, { action = "call" })
-- we already flop before player 3 did anything
-- that is because that player was put all in
-- by the blind
t.assert_eq(GameState.FLOP, game.state)

-- premove error
game:player_action(3, { action = "check" })
t.assert_eq("You are already all in, wait until next round", ddnetpp.get_chat_line(3, -1))

t.all_check(game)
t.assert_eq(GameState.TURN, game.state)

t.all_check(game)
t.assert_eq(GameState.RIVER, game.state)

t.all_check(game)
t.next_showdown_card(game)
t.assert_eq(GameState.PRE_FLOP, game.state)
