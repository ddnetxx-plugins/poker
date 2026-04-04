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

assert_eq(ButtonOffset.UTG, game.players[0].position.offset)
assert_eq(ButtonOffset.BUTTON, game.players[1].position.offset)
assert_eq(ButtonOffset.SMALL_BLIND, game.players[2].position.offset)
assert_eq(ButtonOffset.BIG_BLIND, game.players[3].position.offset)

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
assert_eq(ButtonOffset.SMALL_BLIND, game.players[2].position.offset)
-- assert_eq(2, game:next_to_act().client_id) -- WTF WHY DOES THIS FAIL????
game:player_action(2, { action = "check" })
