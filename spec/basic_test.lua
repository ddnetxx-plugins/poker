local assert_eq = require("simple.assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

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

for i = 0, 127, 1 do
	game:on_snap(i)
end
game:on_tick()

-- preflop
assert_eq(0, #game.community_cards)

game:player_action(0, { action = "check" })

-- still preflop
assert_eq(0, #game.community_cards)

game:player_action(1, { action = "check" })

-- flop
assert_eq(3, #game.community_cards)
