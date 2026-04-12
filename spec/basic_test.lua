local t = require("spec.util.test_base")
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(
	nil,
	{
		x = 33,
		y = 30,
	}
)

game:join_table(0) -- bb
game:join_table(1) -- btn/sb <- first to act

game:new_game()

for i = 0, 127, 1 do
	game:on_snap(i)
end
game:on_tick()

t.assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(0).position.offset)
t.assert_eq(ButtonOffset.BUTTON, game:find_player(1).position.offset)

-- preflop
t.assert_eq(0, #game.community_cards)

-- premove check
t.assert_eq(1, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
t.assert_eq(1, game:next_to_act().client_id)

-- still preflop
t.assert_eq(0, #game.community_cards)

game:player_action(1, { action = "call" })

-- premove failed so try again
game:player_action(0, { action = "check" })

t.assert_eq("'mock1' did a call", ddnetpp.get_chat_line(1, -3))
t.assert_eq("'mock0' did a check", ddnetpp.get_chat_line(1, -2))
t.assert_eq("next round!", ddnetpp.get_chat_line(1, -1))

-- flop
t.assert_eq(3, #game.community_cards)

-- this time we check in the correct order
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- turn
t.assert_eq(4, #game.community_cards)

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
