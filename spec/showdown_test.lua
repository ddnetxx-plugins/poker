local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
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
t.all_check_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")
t.assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))

-- two ace kicker quads split pot
t.set_hole_cards(game, 0, "🂡🂮") -- ace kicker for quads
t.set_hole_cards(game, 1, "🂱🃁") -- same ace kicker for quads
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")
t.all_check_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")
t.assert_eq("You won a split pot with 0 chips in it!", ddnetpp.get_chat_line(0, -3)) -- TODO: who yoinked the blinds xd
t.assert_eq("'mock0' won the split pot with four of a kind (quad fours)", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock1' won the split pot with four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))
