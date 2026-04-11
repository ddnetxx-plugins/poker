-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
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

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:new_game()

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃑🃞

-- ace kicker wins quads
set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
set_hole_cards(game, 1, "🂢🂣")
set_hole_cards(game, 2, "🂵🃅")
set_hole_cards(game, 3, "🃋🃛")
all_check_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")
assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))

-- two ace kicker quads split pot
set_hole_cards(game, 0, "🂡🂮") -- ace kicker for quads
set_hole_cards(game, 1, "🂱🃁") -- same ace kicker for quads
set_hole_cards(game, 2, "🂵🃅")
set_hole_cards(game, 3, "🃋🃛")
all_check_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")
assert_eq("You won a split pot with 0 chips in it!", ddnetpp.get_chat_line(0, -3)) -- TODO: who yoinked the blinds xd
assert_eq("'mock0' won the split pot with four of a kind (quad fours)", ddnetpp.get_chat_line(0, -2))
assert_eq("'mock1' won the split pot with four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))
