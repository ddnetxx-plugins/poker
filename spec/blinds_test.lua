-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 }, 5)
game:join_table(0)
game:join_table(1) -- button
game:join_table(2) -- small blind
game:join_table(3) -- big blind
game:join_table(4) -- UTG
game:new_game()

game:on_tick()

assert_eq(true, game:find_player(1).is_button)
assert_eq(4, game:next_to_act().client_id)

-- game:player_action(0, { action = "check" })
