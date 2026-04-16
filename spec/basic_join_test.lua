local t = require("spec.util.test_base")
require("../src/poker")

-- this test should simulate a somewhat realistic game state
-- of players trying to start a game
-- players will join ticks will pass
-- they wait for others to join
-- get bored and leave and so on

---If you want to check the hud broadcast make sure to use a
---high enough amount. Because it only gets printed every 10
---ticks.
---@param game Poker
---@param amount integer # Amount of server ticks to be simulated
local function fake_server_ticks(game, amount)
	for _ = 1, amount do
		for client_id = 0, 127, 1 do
			game:on_snap(client_id)
		end
		game:on_tick()
		ddnetpp.ticks_passed = ddnetpp.ticks_passed + 1
	end
end

local function trim(s)
   return s:match( "^%s*(.-)%s*$" )
end

local game = Poker:new(nil, { x = 33, y = 30 }, 6)

-- forward compatible tests with locked properties
game.start_stack = 50000
game.num_players_needed_to_start = 4
game.small_blind = 50

fake_server_ticks(game, 20)
game:join_table(0)
t.assert_eq(GameState.WAITING_FOR_PLAYERS, game.state)

fake_server_ticks(game, 20)
t.assert_eq(GameState.WAITING_FOR_PLAYERS, game.state)

game:join_table(1)
fake_server_ticks(game, 20)
t.assert_eq(GameState.WAITING_FOR_PLAYERS, game.state)

t.assert_eq([[waiting for players ... (2 out of 4)
your stack: 50000
paid into pod: 0
you can /check or /raise]], trim(ddnetpp.get_broadcast_line(0, -1)))

game:leave_table(1)
fake_server_ticks(game, 20)
t.assert_eq(GameState.WAITING_FOR_PLAYERS, game.state)

t.assert_eq([[waiting for players ... (1 out of 4)
your stack: 50000
paid into pod: 0
you can /check or /raise]], trim(ddnetpp.get_broadcast_line(0, -1)))

-- last player left the table is empty
game:leave_table(0)
fake_server_ticks(game, 20)

-- same ids rejoin in different order
game:join_table(1)
fake_server_ticks(game, 20)
game:join_table(0)
fake_server_ticks(game, 20)

-- and a new player joins
game:join_table(3)
fake_server_ticks(game, 20)

t.assert_eq([[waiting for players ... (3 out of 4)
your stack: 50000
paid into pod: 0
you can /check or /raise]], trim(ddnetpp.get_broadcast_line(0, -1)))

-- enough players now!
game:join_table(16)
fake_server_ticks(game, 20)

-- game started and blinds have been placed
t.assert_eq([[pot: 150
players with cards: 4
your stack: 50000
paid into pod: 0
you can /fold, /call or /raise (100 to call)]], trim(ddnetpp.get_broadcast_line(0, -1)))

-- first rage quit preflop xd
game:leave_table(16)
fake_server_ticks(game, 20)
t.assert_eq("'mock16' left the table", ddnetpp.get_chat_line(0, -1))

-- new player tries to join running game but fails
game:join_table(32)
fake_server_ticks(game, 20)
t.assert_eq("Only 3 players remaining, wait until the next game", ddnetpp.get_chat_line(32, -1))

-- 3 players remaining and they are sorted by join order
local players = game:players_with_chips()
t.assert_eq(3, #players)
t.assert_eq(1, players[1].client_id)
t.assert_eq(0, players[2].client_id)
t.assert_eq(3, players[3].client_id)

game:leave_table(3)
fake_server_ticks(game, 20)

game:leave_table(1)
fake_server_ticks(game, 20)

t.assert_eq("'mock0' won the entire game! And collected 60 in prize money!", ddnetpp.get_chat_line(0, -1))
