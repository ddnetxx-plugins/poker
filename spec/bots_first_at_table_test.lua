local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 }, 6)

-- forward compatible tests with locked properties
game.start_stack = 50000
game.num_players_needed_to_start = 4
game.small_blind = 50
game.double_blind_interval_minutes = 15
game.buy_in = 10

t.assert_eq(true, game:add_bot()) -- utg
t.assert_eq(true, game:add_bot()) -- btn
game:join_table(0) -- sb
game:join_table(1) -- bb

-- the bots get pretty high client ids
-- because there are a bunch of fake humans connected
t.assert_eq(48, game.players[1].client_id)
t.assert_eq(49, game.players[2].client_id)

-- auto start with 4 players
t.fake_server_ticks(game, 1)
t.assert_eq(GameState.PRE_FLOP, game.state)

t.assert_eq(true, game:find_player(49).is_button)
t.assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(0).position.offset)
t.assert_eq(ButtonOffset.BIG_BLIND, game:find_player(1).position.offset)
t.assert_eq(ButtonOffset.UTG, game:find_player(48).position.offset)

t.assert_eq(48, game:next_to_act().client_id)
t.fake_server_ticks(game, 1)
t.assert_eq(49, game:next_to_act().client_id)
t.fake_server_ticks(game, 1)
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })
t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

t.assert_eq(GameState.FLOP, game.state)

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
t.fake_server_ticks(game, 1)
t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
t.fake_server_ticks(game, 1)

t.assert_eq(GameState.TURN, game.state)

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
t.fake_server_ticks(game, 1)
t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
t.fake_server_ticks(game, 1)

t.assert_eq(GameState.RIVER, game.state)

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
t.fake_server_ticks(game, 1)
t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
t.fake_server_ticks(game, 1)

t.assert_eq(GameState.SHOWDOWN, game.state)

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "show" })

-- bro why does 48 have to act now??? that player folded
-- preflop?????
t.assert_eq(GameState.SHOWDOWN, game.state)
t.assert_eq(48, game:next_to_act().client_id)
