local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb

-- the small blind happens to be omegarich
-- and he will raise big a lot :D
-- making calling quite expensive
-- for the brokies
game:find_player(2).chips = game.start_stack * 10

game:new_game()

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃑🃞

-- ace kicker wins quads
t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")

game:player_action(0, { action = "call" })
game:player_action(1, { action = "call" })
-- omg this is personal :D
game:player_action(2, { action = "raise", amount = game:find_player(0).chips * 2 })
game:player_action(3, { action = "call" })
t.assert_eq("This call made you go all in!", ddnetpp.get_chat_line(3, -1))
t.assert_eq(0, game:find_player(3).chips)
t.assert_eq(2, #game:find_player(3).hole_cards)

game:player_action(0, { action = "call" })
t.assert_eq("This call made you go all in!", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock0' did a call", ddnetpp.get_chat_line(0, -1))
t.assert_eq(0, game:find_player(0).chips)
t.assert_eq(2, #game:find_player(0).hole_cards)

game:player_action(1, { action = "fold" })
t.assert_eq(49900, game:find_player(1).chips)
t.assert_eq(0, #game:find_player(1).hole_cards)

-- TODO: how much sense does flop make here?
--       there is only one player with chips and cards left
--       should skip straight to showdown
--       but then its hard for the unit test to rig the board haha
--       i guess this should happen on tick for unit test
--       and to be dramatic in game
t.assert_eq(GameState.FLOP, game.state)

-- t.rig_board(game, "🂤🂴🃄🃔🃕")

-- t.assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))
