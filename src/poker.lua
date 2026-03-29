function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or "./"
end

local snap = require(script_path() .. "snap")
require(script_path() .. "player")

-- The main class representing an entire game state
-- there can be multiple instances if you want to play
-- multiple games at once

GameState = {
	PRE_FLOP = 1,
	FLOP = 2,
	TURN = 3,
	RIVER = 4,
}

---@class PlayerAction
---@field action string
---|"'check'"
---|"'bet'"
---|"'call'"
---|"'raise'"
---|"'fold'"
---@field amount? integer # Absolute amount in chip value
---@field announced? boolean # True if this action was already announced to other players, can stay false|nil longer for pre moves

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
	state = GameState.PRE_FLOP,
	---@type integer[]
	community_card_snap_ids = {},
}

CARDS = {
	"🂡", "🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂬", "🂭", "🂮", -- Spades
	"🂱", "🂲", "🂳", "🂴", "🂵", "🂶", "🂷", "🂸", "🂹", "🂺", "🂻", "🂼", "🂽", "🂾", -- Hearts
	"🃁", "🃂", "🃃", "🃄", "🃅", "🃆", "🃇", "🃈", "🃉", "🃊", "🃋", "🃌", "🃍", "🃎", -- Diamonds
	"🃑", "🃒", "🃓", "🃔", "🃕", "🃖", "🃗", "🃘", "🃙", "🃚", "🃛", "🃜", "🃝", "🃞", -- Clubs
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
	self.community_card_snap_ids = {}
	self.deck = {}
	return o
end

---@param array table
---@return table
function shuffle(array)
   local shuffled_array = {}
   for i = #array, 1, -1 do
      local j = math.random(i)
      array[i], array[j] = array[j], array[i]
      table.insert(shuffled_array, array[i])
   end
   return shuffled_array
end

function Poker:shuffled_deck()
	return shuffle(CARDS)
end

function Poker:new_game()
	self.state = GameState.PRE_FLOP

	-- TODO: this is really bad and can be cracked easily -.-
	--       should use something like https://github.com/luau-project/lua-cryptorandom
	--       or at least a admin configurable seed
	--       maybe we can also ask the server for a random number
	--       https://github.com/DDNetPP/DDNetPP/issues/548
	math.randomseed(os.time())
	self.deck = self:shuffled_deck()

	if #self.community_card_snap_ids == 0 then
		-- TODO: how to not collide with actual client ids here?
		--       also how to not collide with other poker tables here?
		--       ddnetpp.snap.new_id() does not seem to be the way to go
		table.insert(self.community_card_snap_ids, 127)
		table.insert(self.community_card_snap_ids, 126)
		table.insert(self.community_card_snap_ids, 125)
		table.insert(self.community_card_snap_ids, 124)
		table.insert(self.community_card_snap_ids, 123)
	end

	for _, player in pairs(self.players) do
		player.hole_cards = self:deal_hole_cards()
		player.action = nil
	end
end

---@return string[] hole_cards # Table with two cards at index 1 and 2
function Poker:deal_hole_cards()
	local cards = {}
	table.insert(cards, table.remove(self.deck, 1))
	table.insert(cards, table.remove(self.deck, 1))
	return cards
end

function Poker:flop()
	-- TODO: assert that flop as not happened yet
	table.insert(self.community_cards, table.remove(self.deck, 1))
	table.insert(self.community_cards, table.remove(self.deck, 1))
	table.insert(self.community_cards, table.remove(self.deck, 1))
end

function Poker:turn()
	table.insert(self.community_cards, table.remove(self.deck, 1))
end

function Poker:river()
	table.insert(self.community_cards, table.remove(self.deck, 1))
end

---TODO: think about premoves and how to queue and show them
---
---@param client_id integer
---@param action PlayerAction
function Poker:player_action(client_id, action)
	-- TODO: can the player be nil here? do we need to check that? Or is that on the callsite?
	local player = self.players[client_id]
	if action.action == "check" then
		player.action = action
	elseif action.action == "bet" then
		player.action = action
	elseif action.action == "call" then
		player.action = action
	elseif action.action == "raise" then
		player.action = action
	elseif action.action == "fold" then
		player.action = action
	else
		assert(false, "Invalid betting action")
	end

	self:check_next_state()
end

function Poker:next_state()
	for _, player in pairs(self.players) do
		player.action = nil
	end

	if self.state == GameState.PRE_FLOP then
		self:flop()
		self.state = GameState.FLOP
	elseif self.state == GameState.FLOP then
		self:turn()
		self.state = GameState.TURN
	elseif self.state == GameState.TURN then
		self:river()
		self.state = GameState.RIVER
	elseif self.state == GameState.RIVER then
		-- TODO: what to do here? xd
	end
end

---@return PokerPlayer|nil
function Poker:next_to_act()
	for _, player in pairs(self.players) do
		if player.action == nil then
			return player
		end
	end
	return nil
end

function Poker:check_next_state()
	if self:next_to_act() == nil then
		self:next_state()
	end
end

---@param message string # Gets sent to all players of the current game
function Poker:send_chat(message)
	-- TODO: there is probably a faster way to only iterate the keys
	for cid, _ in pairs(self.players) do
		ddnetpp.send_chat_target(cid, message)
	end
end

function Poker:print_betting_actions()
	for _, player in pairs(self.players) do
		if player.action == nil then
			-- print("waiting for " .. player.client_id)
			-- stop here to not leak pre moves
			return
		end

		if not player.action.announced then
			-- TODO: also do some laser text above their had
			--       so external spectators who do not receive the chat message know what is happening too
			--       or send the chat message also to close by players
			self:send_chat("someone did something xd")
			player.action.announced = true
		end
	end
end

function Poker:on_tick()
	self:print_betting_actions()
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

		local snap_id = self.community_card_snap_ids[i]
		snap.display_card(
			snap_id,
			{
				x = self.table.pos.x + i,
				y = self.table.pos.y,
			},
			card)
	end

	local next_to_act = self:next_to_act()
	if next_to_act ~= nil then
		local chr_next = ddnetpp.get_character(next_to_act.client_id)
		if chr_next then
			ddnetpp.snap.new_laser({
				id = snap_id,
				pos = {
					x = chr_next:pos().x,
					y = chr_next:pos().y - 2,
				}
			})
		end
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
---@return boolean
function Poker:is_at_table(client_id)
	if self.players[client_id] == nil then
		return false
	end
	return true
end

---@param client_id integer
function Poker:join_table(client_id)
	self.players[client_id] = PokerPlayer:new(nil, client_id)
end
