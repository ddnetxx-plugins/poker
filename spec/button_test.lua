-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0)
game:join_table(1)
game:new_game()

game:on_tick()

-- first player that joins will get the button
-- but it moves on the start of the first round
-- so the actual first button is the second joiner
assert_eq(false, game.players[0].is_button)
assert_eq(true, game.players[1].is_button)

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- after one round of betting the button should
-- NOT have moved yet
assert_eq(GameState.FLOP, game.state)
assert_eq(false, game.players[0].is_button)
assert_eq(true, game.players[1].is_button)

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })
assert_eq(GameState.TURN, game.state)

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- also on the river the button should not have moved
-- NOT have moved yet
assert_eq(GameState.RIVER, game.state)
assert_eq(false, game.players[0].is_button)
assert_eq(true, game.players[1].is_button)

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- both players checked on the river the round is over
-- we are pre flop in the next round
-- NOW we expect the button to have moved to the next player
assert_eq(GameState.PRE_FLOP, game.state)
assert_eq(true, game.players[0].is_button)
assert_eq(false, game.players[1].is_button)

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- another button move
assert_eq(GameState.PRE_FLOP, game.state)
assert_eq(false, game.players[0].is_button)
assert_eq(true, game.players[1].is_button)
