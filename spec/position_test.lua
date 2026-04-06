-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 }, 8)
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
assert_eq(false, game:find_player(0).is_button)
assert_eq(true, game:find_player(1).is_button)

assert_eq(ButtonOffset.BUTTON, game:find_player(1).position.offset)
assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(2).position.offset)
assert_eq(ButtonOffset.BIG_BLIND, game:find_player(3).position.offset)
assert_eq(ButtonOffset.UTG, game:find_player(4).position.offset)
assert_eq(ButtonOffset.UTG+1, game:find_player(5).position.offset)
assert_eq(ButtonOffset.UTG+2, game:find_player(6).position.offset)
assert_eq(ButtonOffset.UTG+3, game:find_player(7).position.offset)

