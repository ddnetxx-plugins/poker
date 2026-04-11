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
t.assert_eq("You do not have enough chips, and all in is not implemented yet xd", ddnetpp.get_chat_line(3, -1))

-- t.rig_board(game, "🂤🂴🃄🃔🃕")

-- t.assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))
