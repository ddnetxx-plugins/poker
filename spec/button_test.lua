-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0)
game:join_table(1)
game:join_table(2)
game:join_table(3)
game:new_game()

game:on_tick()

-- first player that joins will get the button
-- so the first player to act is the second joiner
-- (because we do not have blinds yet lol)

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

