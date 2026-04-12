local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb

game:find_player(2).chips = game.start_stack * 2
game:find_player(3).chips = game.start_stack * 4

game:new_game()

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃑🃞

-- FIXME: rig the game here so the slow showdown will cause one final player to win the entire game
--        to make sure the entire game win check is also called correctly in that case
