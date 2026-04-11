local assert_eq = require("spec.simple_assert").assert_eq

ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

---@param game Poker
local function all_check(game)
	for _, player in ipairs(game:players_with_chips()) do
		game:player_action(player.client_id, { action = "check" })
	end
end

---@param game Poker
---@param board_str string # 5 community cards as unicode string
local function all_check_till_showdown_and_rig_board(game, board_str)
	assert_eq(GameState.PRE_FLOP, game.state)
	all_check(game)
	assert_eq(GameState.FLOP, game.state)
	all_check(game)
	assert_eq(GameState.TURN, game.state)
	all_check(game)
	assert_eq(GameState.RIVER, game.state)
	game.community_cards = {}
	for i = 0, 4 do
		local start = i * 4 + 1
		local card = string.sub(board_str, start, start + 3)
		table.insert(game.community_cards, card)
	end
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
	all_check_till_showdown_and_rig_board = all_check_till_showdown_and_rig_board,
	set_hole_cards = set_hole_cards,
}
