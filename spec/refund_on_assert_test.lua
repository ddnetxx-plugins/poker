local t = require("spec.util.test_base")
require("../src/poker")

---@param game Poker
local function assert_crash_game(game)
	game:assert(false, "intentional assert crash")
end

local game = Poker:new(nil, { x = 33, y = 30 }, 6)

-- forward compatible tests with locked properties
game.start_stack = 50000
game.num_players_needed_to_start = 4
game.small_blind = 50
game.buy_in = 10

t.assert_eq(5000000, ddnetpp.get_player(0):money())

t.fake_server_ticks(game, 20)
game:join_table(0)
t.fake_server_ticks(game, 20)
t.assert_eq(GameState.WAITING_FOR_PLAYERS, game.state)

t.assert_eq("-10 (poker buy in)", ddnetpp.get_money_transaction_line(0, -1))
t.assert_eq(4999990, ddnetpp.get_player(0):money())

local ok, error_msg = pcall(assert_crash_game, game)
t.assert_eq(false, ok)
t.assert_str_match("refund_on_assert_test.lua:6: intentional assert crash", error_msg)

t.assert_eq("+10 (refund poker buy in)", ddnetpp.get_money_transaction_line(0, -1))
t.assert_eq(5000000, ddnetpp.get_player(0):money())
