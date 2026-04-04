-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- bb
game:join_table(1) -- btn
game:join_table(2) -- sb
game:new_game()

-- pre flop
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

-- flop
assert_eq(GameState.FLOP, game.state)

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- turn
assert_eq(GameState.TURN, game.state)

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- river
assert_eq(GameState.RIVER, game.state)

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- pre flop (button moved)
--
-- before:
-- cid=0 bb
-- cid=1 btn
-- cid=2 sb
--
-- now:
-- cid=0 sb
-- cid=1 bb
-- cid=2 btn
assert_eq(GameState.PRE_FLOP, game.state)
assert_eq(true, game.players[2].is_button)
assert_eq(ButtonOffset.SMALL_BLIND, game.players[0].position.offset)

-- button first to act pre flop
assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

-- then the sb
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- flop
assert_eq(GameState.FLOP, game.state)

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })
