-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- sb
game:join_table(1) -- btn
game:new_game()

-- pre flop
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- flop
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- turn
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- river
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

--

-- pre flop (button moved)
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

-- flop
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

-- turn
assert_eq(1, game:next_to_act().client_id)
game:player_action(0, { action = "check" }) -- premove
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
assert_eq(GameState.RIVER, game.state)

-- river
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

-- flop (button moved back to original position)

-- copy pasted test from first section:

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- flop
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- turn
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- river
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
