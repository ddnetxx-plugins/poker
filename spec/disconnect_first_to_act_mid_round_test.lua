local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 }, 6)

-- forward compatible tests with locked properties
game.start_stack = 50000
game.num_players_needed_to_start = 4
game.small_blind = 50
game.double_blind_interval_minutes = 15
game.buy_in = 10

game:join_table(0)
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb

-- auto start with 4 players
t.fake_server_ticks(game, 20)
t.assert_eq(GameState.PRE_FLOP, game.state)

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })

-- button is next to act
t.assert_eq(1, game:next_to_act().client_id)

-- simulate small blind disconnect
game:leave_table(2)
ddnetpp.players[2] = nil
t.fake_server_ticks(game, 2)

-- button is still next to act
t.assert_eq(1, game:next_to_act().client_id)

game:player_action(1, { action = "call" })
t.assert_eq("'mock1' called", ddnetpp.get_chat_line(1, -1))

t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "check" })
