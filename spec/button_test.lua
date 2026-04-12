local t = require("spec.util.test_base")
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- sb
game:join_table(1) -- btn
game:new_game()

-- first player that joins will get the button
-- but it moves on the start of the first round
-- so the actual first button is the second joiner
t.assert_eq(false, game:find_player(0).is_button)
t.assert_eq(true, game:find_player(1).is_button)

game:player_action(0, { action = "call" })
game:player_action(1, { action = "check" })

-- after one round of betting the button should
-- NOT have moved yet
t.assert_eq(GameState.FLOP, game.state)
t.assert_eq(false, game:find_player(0).is_button)
t.assert_eq(true, game:find_player(1).is_button)

t.assert_eq(GameState.FLOP, game.state)
game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })
t.assert_eq(GameState.TURN, game.state)

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- also on the river the button should not have moved
-- NOT have moved yet
t.assert_eq(GameState.RIVER, game.state)
t.assert_eq(false, game:find_player(0).is_button)
t.assert_eq(true, game:find_player(1).is_button)

game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

-- both players checked on the river the round is over
-- we are pre flop in the next round
-- NOW we expect the button to have moved to the next player
t.assert_eq(GameState.PRE_FLOP, game.state)
t.assert_eq(true, game:find_player(0).is_button)
t.assert_eq(false, game:find_player(1).is_button)

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "call" })
game:player_action(0, { action = "check" })
t.assert_eq(GameState.FLOP, game.state)

game:player_action(1, { action = "check" })
game:player_action(0, { action = "check" })
t.assert_eq(GameState.TURN, game.state)

game:player_action(1, { action = "check" })
game:player_action(0, { action = "check" })
t.assert_eq(GameState.RIVER, game.state)

game:player_action(1, { action = "check" })


t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

-- t.assert_eq("", ddnetpp.get_chat_line(0, -1))

-- another button move
t.assert_eq(GameState.PRE_FLOP, game.state)
t.assert_eq(false, game:find_player(0).is_button)
t.assert_eq(true, game:find_player(1).is_button)
