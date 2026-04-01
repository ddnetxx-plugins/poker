local assert_eq = require("simple.assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

local got = 2
assert_eq(2, got)

local game = Poker:new(
	nil,
	{
		x = 33,
		y = 30,
	}
)

game:join_table(0)
game:join_table(1)

game:new_game()
