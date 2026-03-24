function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or "./"
end

local snap = require(script_path() .. "snap")
require(script_path() .. "player")

-- The main class representing an entire game state
-- there can be multiple instances if you want to play
-- multiple games at once

---@class Poker
Poker = {
	table = {
		pos = {
			x = 0,
			y = 0,
		}
	},
	---@type PokerPlayer[]
	players = {},
	---@type string[]
	community_cards = {},
	---@type string[]
	deck = {},
}

CARDS = {
	{ "🂡", "🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂬", "🂭", "🂮" }, -- Spades
	{ "🂱", "🂲", "🂳", "🂴", "🂵", "🂶", "🂷", "🂸", "🂹", "🂺", "🂻", "🂼", "🂽", "🂾" }, -- Hearts
	{ "🃁", "🃂", "🃃", "🃄", "🃅", "🃆", "🃇", "🃈", "🃉", "🃊", "🃋", "🃌", "🃍", "🃎" }, -- Diamonds
	{ "🃑", "🃒", "🃓", "🃔", "🃕", "🃖", "🃗", "🃘", "🃙", "🃚", "🃛", "🃜", "🃝", "🃞" }, -- Clubs
}

---@param o Poker|nil
---@param table_pos Position
---@return any
function Poker:new(o, table_pos)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.table = {}
	self.table.pos = table_pos or { x = 0, y = 0 }
	self.players = {}
	self.community_cards = {}
	self.deck = {}
	return o
end

function Poker:new_game()
	ddnetpp.log_info("starting new game..")
	for _, player in pairs(self.players) do
		ddnetpp.log_info("player " .. player.client_id .. " got hole cards")
		player.hole_cards = self:deal_hole_cards()
	end
end

---@return string[] hole_cards # Table with two cards at index 1 and 2
function Poker:deal_hole_cards()
	-- haters would say this is rigged
	return {
		"🃄", "🃝",
	}
end

function Poker:flop()
	-- TODO: assert that flop as not happened yet
	table.insert(self.community_cards, CARDS[1][1])
	table.insert(self.community_cards, CARDS[1][1])
	table.insert(self.community_cards, CARDS[1][1])
end

function Poker:on_snap(snapping_client)
	-- TODO: only snap to participants
	--       or maybe keep snapping to all? so others can watch

	-- TODO: use proper ids
	local snap_id = 10

	for i, card in pairs(self.community_cards) do
		-- TODO: omg lua is so troll it moves the reference of a table with = operator
		--       i wanted to do local pos = self.table.pos and then increment the x
		--       maybe the C++ api is bad then if we cant use the table field nicely anyways

		snap.display_card(
			snap_id + i,
			{
				x = self.table.pos.x + i,
				y = self.table.pos.y,
			},
			card)
	end

	local poker_player = self.players[snapping_client]
	local chr = ddnetpp.get_character(snapping_client)
	if poker_player ~= nil and chr ~= nil then
		local pos = chr:pos()
		pos.x = pos.x - 1.5
		pos.y = pos.y - 2
		for i, card in pairs(poker_player.hole_cards) do
			pos.x = pos.x + 0.9
			snap.display_card(
				snap_id + i + 4,
				pos,
				card)
		end
	end
end

---@param client_id integer
function Poker:join_table(client_id)
	self.players[client_id] = PokerPlayer:new(nil, client_id)
end
