local assert_eq = require("simple.assert").assert_eq
local t = require("spec.util.test_base")
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- bb
game:join_table(1) -- btn/sb <- (first preflop, second post flop)
game:new_game()

assert_eq(true, game:find_player(1).is_button)

-- pre flop
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "call" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

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
t.all_show(game)
t.next_showdown_card(game)

--

-- pre flop (button moved)
assert_eq(true, game:find_player(0).is_button)

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

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
assert_eq(GameState.TURN, game.state) -- premove failed to change state

game:player_action(0, { action = "check" }) -- retry failed premove

assert_eq(GameState.RIVER, game.state)

-- river
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
t.all_show(game)
t.next_showdown_card(game)

-- pre flop (button moved back to original position)
assert_eq(false, game:find_player(0).is_button)
assert_eq(true, game:find_player(1).is_button)

-- copy pasted test from first section:

-- pre flop
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "call" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

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
