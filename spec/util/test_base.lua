local assert_eq = require("simple.assert").assert_eq

ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

---@param game Poker
local function all_check(game)
	for _, player in ipairs(game:sort_players_by_position()) do
		if player.chips_paid_into_pot < game.pot_per_player then
			game:player_action(player.client_id, { action = "call" })
		else
			game:player_action(player.client_id, { action = "check" })
		end
	end
end

---If the game is in showdown state where no player can act anymore
---because 1 or less players still has chips and the remaining players
---are already all in or folded.
---
---In that state the cards get revealed slowly. So after one second
---of waiting we get the flop then another second later the turn and so on.
---
---Time is a bit rigged in unit tests of course because we have no game loop
---so this helper simulates a time progress of exactly one showdown stage.
---@param game Poker
local function next_showdown_card(game)
	assert_eq(true, game.is_showdown)
	local expected_state = game.state + 1
	if game.state == GameState.RIVER then
		expected_state = GameState.PRE_FLOP
	end
	for _ = 1, math.ceil(game.showdown_speed * ddnetpp.server.tick_speed()) do
		game:on_tick()
	end
	assert_eq(expected_state, game.state)
end

---@param game Poker
---@param board_str string # 5 community cards as unicode string
local function rig_board(game, board_str)
	assert(game.state == GameState.RIVER, "the board can only be rigged on the river")
	game.community_cards = {}
	for i = 0, 4 do
		local start = i * 4 + 1
		local card = string.sub(board_str, start, start + 3)
		table.insert(game.community_cards, card)
	end
end

---@param game Poker
---@param board_str string # 5 community cards as unicode string
local function all_check_call_till_showdown_and_rig_board(game, board_str)
	assert_eq(GameState.PRE_FLOP, game.state)
	all_check(game)
	assert_eq(GameState.FLOP, game.state)
	all_check(game)
	assert_eq(GameState.TURN, game.state)
	all_check(game)
	assert_eq(GameState.RIVER, game.state)
	rig_board(game, board_str)
	all_check(game)
	assert_eq(GameState.PRE_FLOP, game.state)
end

---@param game Poker
---@param client_id integer
---@param hole_cards_str any
local function set_hole_cards(game, client_id, hole_cards_str)
	local player = game:find_player(client_id)
	assert(player ~= nil, "player with client id " .. client_id .. " not found")
	player.hole_cards = {}
	table.insert(player.hole_cards, string.sub(hole_cards_str, 1, 4))
	table.insert(player.hole_cards, string.sub(hole_cards_str, 5, 8))
end

return {
	assert_eq = assert_eq,

	all_check = all_check,
	next_showdown_card = next_showdown_card,
	all_check_call_till_showdown_and_rig_board = all_check_call_till_showdown_and_rig_board,
	rig_board = rig_board,
	set_hole_cards = set_hole_cards,
}
