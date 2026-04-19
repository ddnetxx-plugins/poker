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
t.fake_server_ticks(game, 20)
t.assert_eq(GameState.PRE_FLOP, game.state)

-- expect utg to be first to act???
t.assert_eq(48, game:next_to_act().client_id)
