-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:new_game()

assert_eq(ButtonOffset.UTG, game:find_player(0).position.offset)
assert_eq(ButtonOffset.BUTTON, game:find_player(1).position.offset)
assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(2).position.offset)
assert_eq(ButtonOffset.BIG_BLIND, game:find_player(3).position.offset)

assert_eq(game.next_to_act_offset, ButtonOffset.UTG)

-- pre flop
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })

-- flop
assert_eq(GameState.FLOP, game.state)
assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(2).position.offset)

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- turn
assert_eq(GameState.TURN, game.state)

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- river
assert_eq(GameState.RIVER, game.state)

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- pre flop (button moved)
-- before:
-- cid=0 utg
-- cid=1 btn
-- cid=2 sb
-- cid=3 bb
--
-- after:
-- cid=0 bb
-- cid=1 utg
-- cid=2 btn
-- cid=3 sb

assert_eq(true, game:find_player(2).is_button)

-- utg first to act
assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
