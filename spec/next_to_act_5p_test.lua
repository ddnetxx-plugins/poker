-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- co
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:join_table(4) -- utg
game:new_game()

assert_eq(ButtonOffset.UTG+1, game.players[0].position.offset)
assert_eq(ButtonOffset.BUTTON, game.players[1].position.offset)
assert_eq(ButtonOffset.SMALL_BLIND, game.players[2].position.offset)
assert_eq(ButtonOffset.BIG_BLIND, game.players[3].position.offset)
assert_eq(ButtonOffset.UTG, game.players[4].position.offset)

assert_eq(game.next_to_act_offset, ButtonOffset.UTG)

-- pre flop
assert_eq(4, game:next_to_act().client_id)
game:player_action(4, { action = "check" })

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

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })

assert_eq(4, game:next_to_act().client_id)
game:player_action(4, { action = "check" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- turn
assert_eq(GameState.TURN, game.state)
game:player_action(2, { action = "check" })
game:player_action(3, { action = "check" })
game:player_action(4, { action = "check" })
game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- river
assert_eq(GameState.RIVER, game.state)
game:player_action(2, { action = "check" })
game:player_action(3, { action = "check" })
game:player_action(4, { action = "check" })
game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- pre flop (button moved)
-- before:
-- cid=0 co
-- cid=1 btn
-- cid=2 sb
-- cid=3 bb
-- cid=4 utg
--
-- after:
-- cid=0 utg
-- cid=1 co
-- cid=2 btn
-- cid=3 sb
-- cid=4 bb
assert_eq(GameState.PRE_FLOP, game.state)

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
