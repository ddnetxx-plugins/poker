local simp_ass = require("simple.assert")
local assert_eq = simp_ass.assert_eq
local assert_ne = simp_ass.assert_ne
local assert_str_match = simp_ass.assert_str_match

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

---Let all players show their cards during showdown
---nobody is hiding a bluff here :D
---@param game Poker
local function all_show(game)
	assert(game.state == GameState.SHOWDOWN, "tried to show player cards during state '" .. gamestate_to_str(game.state) .. "' expected showdown")

	local prev_to_act_id = nil

	-- TODO: this order is wrong but so is the actual code order xd
	for _ = 1, 100 do
		local player = game:next_to_act()
		if player == nil then
			return
		end
		if prev_to_act_id == player.client_id then
			local msg = ddnetpp.get_chat_line(player.client_id, -1)
			print("[test][card show error][chat] *** " .. msg)
			assert(false, "tried to show cid=" .. player.client_id .. " card but next to act did not change")
			return
		end
		prev_to_act_id = player.client_id
		game:player_action(player.client_id, { action = "show" })
	end
	assert(false, "failed to show all players cards during showdown")
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
	assert(game.is_showdown == true, "tried to show next showdown card but the board is not running (current_state=" .. gamestate_to_str(game.state) .. ")")
	local old_state = game.state
	local ticks = game.ticks_till_next_showdown_card
	for _ = 1, ticks do
		game:on_tick()
	end
	if old_state == GameState.SHOWDOWN then
		assert(
			game.state == GameState.PRE_FLOP or game.state == GameState.END,
			"got state '" .. gamestate_to_str(game.state) .. "' after showdown (expected 'end' or 'pre_flop')"
		)
	else
		assert_eq(old_state + 1, game.state)
	end
end

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
	if game.is_showdown then
		next_showdown_card(game)
	end
	assert_eq(GameState.SHOWDOWN, game.state)
	all_show(game)
	-- this name is not ideal because it is not showing a new card
	-- its just progressing time because after all players showed
	-- their cards there is a delay
	next_showdown_card(game)
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
	assert_ne = assert_ne,
	assert_str_match = assert_str_match,

	all_check = all_check,
	all_show = all_show,
	next_showdown_card = next_showdown_card,
	fake_server_ticks = fake_server_ticks,
	all_check_call_till_showdown_and_rig_board = all_check_call_till_showdown_and_rig_board,
	rig_board = rig_board,
	set_hole_cards = set_hole_cards,
}
