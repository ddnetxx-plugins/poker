-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 }, 5)
game:join_table(0) -- co
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:join_table(4) -- utg
game:new_game()

game:leave_table(4)
