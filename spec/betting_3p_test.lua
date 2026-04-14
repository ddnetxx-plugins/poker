local assert_eq = require("simple.assert").assert_eq
local t = require("spec.util.test_base")
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
game:player_action(1, { action = "call" })

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "call" })

assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "bet", amount = 2 })

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
assert_eq("You can not check. You need to pay at least 2 chips to call.", ddnetpp.get_chat_line(1, -1))

assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "call" })

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })
assert_eq("You can not check. You need to pay at least 2 chips to call.", ddnetpp.get_chat_line(2, -1))

assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "call" })

-- flop
assert_eq(GameState.FLOP, game.state)
assert_eq(306, game.pot)
game:player_action(2, { action = "check" })
game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- turn
assert_eq(GameState.TURN, game.state)
game:player_action(2, { action = "bet", amount = 2 })
game:player_action(0, { action = "call" })
game:player_action(1, { action = "call" })

-- river
assert_eq(GameState.RIVER, game.state)
assert_eq(312, game.pot)
game:player_action(2, { action = "bet", amount = 2 })
game:player_action(0, { action = "raise", amount = 20 })
game:player_action(1, { action = "call" })
assert_eq(GameState.RIVER, game.state) -- still river because, sb got reraised
game:player_action(2, { action = "call" })
t.all_show(game)
t.next_showdown_card(game)

-- some player won, new round
assert_eq(GameState.PRE_FLOP, game.state)
