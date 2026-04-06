-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- button
game:join_table(2) -- small blind
game:join_table(3) -- big blind
game:new_game()

game:on_tick()

game:player_action(0, { action = "raise", amount = 10 })
game:player_action(1, { action = "raise", amount = 10 })
