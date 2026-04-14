local t = require("spec.util.test_base")
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

-- I AM PRETTY SURE THAT THIS TEST IMPLEMENTS THE CORRECT RULES!
-- FOR THE NASTY HEADSUP EDGE CASE

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- bb
game:join_table(1) -- btn,sb (first preflop, second post flop)
game:new_game()

-- button placed small blind
t.assert_eq(game.start_stack - game.small_blind, game:find_player(1).chips)

-- other player places big blind
t.assert_eq(game.start_stack - game.small_blind * 2, game:find_player(0).chips)

-- first to act is the button preflop
t.assert_eq(1, game:next_to_act().client_id)

-- button catches up to big blind
game:player_action(1, { action = "call" })
-- big blind does not raise
game:player_action(0, { action = "check" })

t.assert_eq(GameState.FLOP, game.state)

-- button is LAST to act post flop
t.assert_eq(0, game:next_to_act().client_id)

-- big blind checks
game:player_action(0, { action = "check" })
-- button checks
game:player_action(1, { action = "check" })

t.assert_eq(GameState.TURN, game.state)

-- button stays last to act post flop
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

t.assert_eq(GameState.RIVER, game.state)

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
game:player_action(1, { action = "check" })

t.next_showdown_card(game)
t.assert_eq(GameState.PRE_FLOP, game.state)

-- now the button moved
-- cid=0 btn,sb (first preflop, second post flop)
-- cid=1 bb

-- button is first to act pre flop
t.assert_eq(true, game:find_player(0).is_button)
t.assert_eq(0, game:find_player(0).client_id)
game:player_action(0, { action = "call" })
game:player_action(1, { action = "check" })

-- and second to act post flop
t.assert_eq(GameState.FLOP, game.state)
game:player_action(1, { action = "check" })
game:player_action(0, { action = "check" })

t.assert_eq(GameState.TURN, game.state)
