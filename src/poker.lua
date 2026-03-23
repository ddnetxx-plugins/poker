function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or "./"
end

local snap = require(script_path() .. "snap")

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
	players = {}
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
	return o
end

function Poker:new_game()
end

function Poker:on_snap()
	local snap_id = 10

	-- TODO: only snap to participants

	snap.display_card(snap_id, self.table.pos, CARDS[1][1])
end

---@param client_id integer
function Poker:join_table(client_id)
	table.insert(self.players, PokerPlayer:new(nil, client_id))
end
