local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 }, 6)

-- forward compatible tests with locked properties
game.start_stack = 50000
game.num_players_needed_to_start = 4
game.small_blind = 50
game.double_blind_interval_minutes = 15
game.buy_in = 10

game:join_table(0) -- utg
game:join_table(1) -- btn
t.assert_eq(true, game:add_bot()) -- sb
t.assert_eq(true, game:add_bot()) -- bb

-- the bots get pretty high client ids
-- because there are a bunch of fake humans connected
t.assert_eq(48, game.players[3].client_id)
t.assert_eq(49, game.players[4].client_id)

-- auto start with 4 players
t.fake_server_ticks(game, 20)
t.assert_eq(GameState.PRE_FLOP, game.state)

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "raise", amount = 2 })

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "call" })

-- bot turn
t.assert_eq(48, game:next_to_act().client_id)
t.fake_server_ticks(game, 1)

-- next bot turn
t.assert_eq(49, game:next_to_act().client_id)
t.fake_server_ticks(game, 1)

t.assert_eq(GameState.FLOP, game.state)

-- two humans on the flop both bots folded
-- will check humans through and still tick bots
-- to make sure they dont start to do random things after folding

t.fake_server_ticks(game, 1)
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
t.fake_server_ticks(game, 1)
t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
t.fake_server_ticks(game, 1)

t.assert_eq(GameState.TURN, game.state)

t.fake_server_ticks(game, 1)
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
t.fake_server_ticks(game, 1)
t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
t.fake_server_ticks(game, 1)

t.assert_eq(GameState.RIVER, game.state)

t.fake_server_ticks(game, 1)
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
t.fake_server_ticks(game, 1)
t.assert_eq(1, game:next_to_act().client_id)
-- game:player_action(1, { action = "check" })
-- t.fake_server_ticks(game, 1)
