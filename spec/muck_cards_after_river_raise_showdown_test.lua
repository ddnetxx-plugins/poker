local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 }, 8)
game:join_table(0) -- co
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:join_table(4) -- utg
game:new_game()

-- ace kicker wins quads
t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")
t.set_hole_cards(game, 4, "🂾🃎")

t.assert_eq(GameState.PRE_FLOP, game.state)
t.all_check(game)

t.assert_eq(GameState.FLOP, game.state)
t.all_check(game)
t.assert_eq(GameState.TURN, game.state)
t.all_check(game)
t.assert_eq(GameState.RIVER, game.state)
t.rig_board(game, "🂤🂴🃄🃔🃕")

game:player_action(2, { action = "check" })
game:player_action(3, { action = "check" })
game:player_action(4, { action = "raise", amount = 2 }) -- utg bets
game:player_action(0, { action = "raise", amount = 2 }) -- co raises on top
t.all_check(game)

t.assert_eq(false, game.is_showdown)
t.assert_eq(GameState.SHOWDOWN, game.state)

-- first aggressor was client 4 but it got raised by client id 0
-- so client id 0 cards get shown first and the remaining players
-- can choose to show their cards clock wise
t.assert_eq("'mock0' showed 🂡🂮", ddnetpp.get_chat_line(1, -1))

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "show" })
t.assert_eq("'mock1' showed 🂢🂣", ddnetpp.get_chat_line(1, -1))

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "show" })
t.assert_eq("'mock2' showed 🂵🃅", ddnetpp.get_chat_line(0, -1))

t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "show" })
t.assert_eq("'mock3' showed 🃋🃛", ddnetpp.get_chat_line(3, -1))

t.assert_eq(4, game:next_to_act().client_id)
game:player_action(4, { action = "show" })
t.assert_eq("'mock4' showed 🂾🃎", ddnetpp.get_chat_line(3, -2))
t.assert_eq("next round!", ddnetpp.get_chat_line(3, -1))
