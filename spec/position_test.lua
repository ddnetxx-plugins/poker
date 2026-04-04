-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- co
game:join_table(1) -- button
game:join_table(2) -- small blind
game:join_table(3) -- big blind
game:join_table(4) -- utg
game:join_table(5) -- utg+1
game:join_table(6) -- lj
game:join_table(7) -- hj
game:new_game()

-- first player that joins will get the button
-- but it moves on the start of the first round
-- so the actual first button is the second joiner
assert_eq(false, game.players[0].is_button)
assert_eq(true, game.players[1].is_button)

assert_eq(ButtonOffset.BUTTON, game.players[1].position.offset)
assert_eq(ButtonOffset.SMALL_BLIND, game.players[2].position.offset)
assert_eq(ButtonOffset.BIG_BLIND, game.players[3].position.offset)
assert_eq(ButtonOffset.UTG, game.players[4].position.offset)
assert_eq(ButtonOffset.UTG+1, game.players[5].position.offset)
assert_eq(ButtonOffset.UTG+2, game.players[6].position.offset)
assert_eq(ButtonOffset.UTG+3, game.players[7].position.offset)

