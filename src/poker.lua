function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or "./"
end

require(script_path() .. "enums")
local snap = require(script_path() .. "snap")
require(script_path() .. "player")

local function gamestate_to_str(state)
	if state == GameState.END then
		return "END"
	elseif state == GameState.ERROR then
		return "ERROR"
	elseif state == GameState.PRE_FLOP then
		return "PRE_FLOP"
	elseif state == GameState.FLOP then
		return "FLOP"
	elseif state == GameState.TURN then
		return "TURN"
	elseif state == GameState.RIVER then
		return "RIVER"
	end
	return "(unknown)"
end

---@class PlayerAction
---@field action string
---|"'check'"
---|"'bet'"
---|"'call'"
---|"'raise'"
---|"'fold'"
---@field amount? integer # Absolute amount in chip value
---@field announced? boolean # True if this action was already announced to other players, can stay false|nil longer for pre moves

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
	state = GameState.PRE_FLOP,
	---@type integer[]
	community_card_snap_ids = {},
}

CARDS = {
	"🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂭", "🂮", "🂡", -- Spades
	"🂲", "🂳", "🂴", "🂵", "🂶", "🂷", "🂸", "🂹", "🂺", "🂻", "🂽", "🂾", "🂱", -- Hearts
	"🃂", "🃃", "🃄", "🃅", "🃆", "🃇", "🃈", "🃉", "🃊", "🃋", "🃍", "🃎", "🃁", -- Diamonds
	"🃒", "🃓", "🃔", "🃕", "🃖", "🃗", "🃘", "🃙", "🃚", "🃛", "🃝", "🃞", "🃑", -- Clubs
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
	self.next_to_act_snap_id = 0
	self.deck = {}
	return o
end

---The full game state as a big multi line string
---this is just for debugging
---@return string gamestate
function Poker:state_to_str()
	local state = "gamestate: " .. gamestate_to_str(self.state)

	for cid, player in pairs(self.players) do
		local btn = ""
		if player.is_button then
			btn = " (button)"
		end
		state = state .. "\n" ..
			"player '" .. ddnetpp.server.client_name(cid) .. "'" .. btn .. "\n" ..
			"  idk xd"
	end

	return state
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

---@return integer|nil client_id
function Poker:find_and_occupy_free_client_id()
	for i = 127, 0, -1 do
		if ddnetpp.server.occupy_client_id(i) then
			return i
		end
	end
	return nil
end

function Poker:move_button()
	local prev_had_button = false
	for _, player in pairs(self.players) do
		if prev_had_button then
			player.is_button = true
			prev_had_button = false
		elseif player.is_button then
			player.is_button = false
			prev_had_button = true
		end
	end
	-- if the last player had the button we need to loop again to
	-- overflow the button to the first player
	if prev_had_button then
		for _, player in pairs(self.players) do
			player.is_button = true
			prev_had_button = false
			break
		end
	end
end

function Poker:init_player_positions()
	local after_button = false
	local offset = 0
	for _, player in pairs(self.players) do
		if player.is_button == true then
			after_button = true
			player.position = {
				name = "button",
				offset = 0,
			}
		elseif after_button then
			offset = offset + 1
			player.position.name = "todo"
			player.position.offset = offset
		end
	end
	for _, player in pairs(self.players) do
		if player.is_button == true then
			break
		end
		offset = offset + 1
		player.position.name = "todo"
		player.position.offset = offset
	end
end

---@param num_players integer
function Poker:place_blinds(num_players)
	for _, player in pairs(self.players) do
		if player.position.offset == ButtonOffset.SMALL_BLIND then
			-- TODO: place small blind here
		else
			local is_big_blind = false
			if player.position.offset == ButtonOffset.BIG_BLIND then
				is_big_blind = true
			end
			if num_players == 2 and player.position.offset == ButtonOffset.BUTTON then
				is_big_blind = true
			end

			if is_big_blind then
				-- TODO: place big blind here
			end
		end
	end
end

function Poker:new_round()
	self.state = GameState.PRE_FLOP
	self.deck = self:shuffled_deck()

	for _, player in pairs(self.players) do
		player.hole_cards = self:deal_hole_cards()
		player.action = nil
	end

	self:move_button()
	self:init_player_positions()

	local num_players = self:num_players()
	self:place_blinds(num_players)

	if num_players == 2 then
		self.next_to_act_offset = ButtonOffset.SMALL_BLIND
	elseif num_players == 3 then
		self.next_to_act_offset = ButtonOffset.BUTTON
	else
		self.next_to_act_offset = ButtonOffset.UTG
	end
end

function Poker:new_game()
	self:new_round()

	math.randomseed(ddnetpp.secure_rand_below(666999))

	if #self.community_card_snap_ids == 0 then
		for _ = 1, 5, 1 do
			local free_id = self:find_and_occupy_free_client_id()
			if free_id == nil then
				ddnetpp.send_chat("failed to start poker game, server is full")
				self.state = GameState.ERROR
				return
			end
			table.insert(self.community_card_snap_ids, free_id)
		end
	end
	self.next_to_act_snap_id = ddnetpp.snap.new_id()
end

function Poker:end_game()
	self.state = GameState.END
	for _, occupied_id in pairs(self.community_card_snap_ids) do
		ddnetpp.server.free_occupied_client_id(occupied_id)
	end
	ddnetpp.snap.free_id(self.next_to_act_snap_id)
	for cid, _ in pairs(self.players) do
		self:leave_table(cid)
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
	-- TODO: assert that flop has not happened yet
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

	if player.action ~= nil then
		-- Premoves can still be changed
		-- as soon as it was announced it can not be changed anymore
		if player.action.announced then
			ddnetpp.send_chat_target(client_id, "wait until next round")
			return
		end
	end

	-- TODO: if someone raises
	--       clear other player actions so they get a turn again
	--       and create a new array prev_actions to store the history
	--       in that case. So we can properly display things such as
	--       3 bet and so on

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

	self:print_betting_actions()
	if self.next_to_act_offset == player.position.offset then
		self:compute_next_to_act()
	end
	self:check_next_state()
end

function Poker:next_state()
	for _, player in pairs(self.players) do
		player.action = nil
	end

	self.next_to_act_offset = ButtonOffset.SMALL_BLIND

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
		self:new_round()
	end
end

---@param offset integer
---@return PokerPlayer|nil
function Poker:get_player_by_position(offset)
	for _, player in pairs(self.players) do
		if player.position.offset == offset then
			return player
		end
	end
	return nil
end

function Poker:compute_next_to_act()
	local prev = self:next_to_act()
	assert(prev ~= nil, "tried to compute next to act but betting round was already over")

	-- still waiting for same player
	if prev.action == nil then
		return
	end

	local num_players = self:num_players()

	if num_players == 2 then
		-- TODO: i feel like this code can be deleted
		if self.next_to_act_offset == ButtonOffset.BUTTON then
			local next_player = self:get_player_by_position(ButtonOffset.SMALL_BLIND)
			assert(next_player ~= nil, "no player after button?")
			if next_player.action == nil then
				-- if button raised its the sb turn again
				self.next_to_act_offset = ButtonOffset.SMALL_BLIND
			else
				self.next_to_act_offset = nil
			end
			return
		elseif self.next_to_act_offset == ButtonOffset.SMALL_BLIND then
			local next_player = self:get_player_by_position(ButtonOffset.BUTTON)
			assert(next_player ~= nil, "no player after big blind?")
			if next_player.action == nil then
				-- if someone raised which cleared
				-- the utg action we continue after the big blind
				self.next_to_act_offset = ButtonOffset.BUTTON
			else
				self.next_to_act_offset = nil
			end
			return
		end
		assert(false, "should be unreachable w 2 players")
	elseif num_players == 3 then
		-- TODO: i feel like this code can be deleted or merged with above
		--       or solved with recursion
		if self.next_to_act_offset == ButtonOffset.BUTTON then
			self.next_to_act_offset = ButtonOffset.SMALL_BLIND
			self:compute_next_to_act()
			return
		elseif self.next_to_act_offset == ButtonOffset.SMALL_BLIND then
			self.next_to_act_offset = ButtonOffset.BIG_BLIND
			self:compute_next_to_act()
			return
		elseif self.next_to_act_offset == ButtonOffset.BIG_BLIND then
			local next_player = self:get_player_by_position(ButtonOffset.BUTTON)
			assert(next_player ~= nil, "no player after big blind?")
			if next_player.action == nil then
				-- if someone raised which cleared
				-- the utg action we continue after the big blind
				self.next_to_act_offset = ButtonOffset.BUTTON
			else
				self.next_to_act_offset = nil
			end
			return
		end
		assert(false, "not implemented")
	end

	-- special case for the blinds
	if self.state == GameState.PRE_FLOP then
		if num_players > 3 then
			if self.next_to_act_offset == ButtonOffset.BUTTON then
				self.next_to_act_offset = ButtonOffset.SMALL_BLIND
				self:compute_next_to_act()
				return
			elseif self.next_to_act_offset == ButtonOffset.SMALL_BLIND then
				self.next_to_act_offset = ButtonOffset.BIG_BLIND
				self:compute_next_to_act()
				return
			elseif self.next_to_act_offset == ButtonOffset.BIG_BLIND then
				local next_player = self:get_player_by_position(ButtonOffset.UTG)
				assert(next_player ~= nil, "no player after big blind?")
				if next_player.action == nil then
					-- if someone raised which cleared
					-- the utg action we continue after the big blind
					self.next_to_act_offset = ButtonOffset.UTG
				else
					self.next_to_act_offset = nil
				end
				return
			end
		end
	end

	-- increment the offset and then recurse
	if self.next_to_act_offset == ButtonOffset.BUTTON then
		self.next_to_act_offset = nil
		return
	end

	self.next_to_act_offset = self.next_to_act_offset + 1

	if self.next_to_act_offset == num_players then
		self.next_to_act_offset = ButtonOffset.BUTTON
	end

	self:compute_next_to_act()
end

---@return PokerPlayer|nil
function Poker:next_to_act()
	if self.next_to_act_offset == nil then
		return nil
	end

	local next_player = self:get_player_by_position(self.next_to_act_offset)
	assert(next_player ~= nil, "failed to find next to act at button_offset=" .. self.next_to_act_offset)
	return next_player
end

function Poker:check_next_state()
	if self:next_to_act() == nil then
		-- TODO: remove
		self:send_chat("next round!")
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

		if player.action.announced == false or player.action.announced == nil then
			-- TODO: also do some laser text above their had
			--       so external spectators who do not receive the chat message know what is happening too
			--       or send the chat message also to close by players

			local chr = ddnetpp.get_character(player.client_id)
			if chr then
				local text_pos = chr:pos()
				text_pos.x = text_pos.x - 8
				text_pos.y = text_pos.y - 8
				ddnetpp.laser_text(text_pos, player.action.action)
			end

			local tw_player = ddnetpp.get_player(player.client_id)
			if tw_player then
				self:send_chat(
					"'" .. tw_player:name() .. "' did a " .. player.action.action
				)
			end
			player.action.announced = true
		end
	end
end

function Poker:on_tick()
	if self.state == GameState.ERROR then
		return
	end
	if self.state == GameState.END then
		return
	end
	self:print_betting_actions()
end

function Poker:on_snap(snapping_client)
	-- TODO: only snap to participants
	--       or maybe keep snapping to all? so others can watch

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
				id = self.next_to_act_snap_id,
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
				poker_player.hole_card_snap_ids[i],
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

---We need a count helper because #self.players does not work as expected
---Because it is not a proper lua array starting at index 1
---it is a hash with the client id as key
---
---I currently have no internet so I came up with this loop.
---TODO: there has to be a better way for getting the amount of keys
---      set in a lua table i just cant lookup stuff right now :D
---@return integer amount
function Poker:num_players()
	local num = 0
	for _ in pairs(self.players) do
		num = num + 1
	end
	return num
end

---@param client_id integer
function Poker:join_table(client_id)
	if self.state == GameState.ERROR then
		return
	end
	local player = PokerPlayer:new(client_id)

	for _ = 1, 2, 1 do
		local snap_id = nil
		snap_id = self:find_and_occupy_free_client_id()
		if snap_id == nil then
			ddnetpp.send_chat_target(client_id, "failed to join poker table, server is full")
			for _, allocated_id in pairs(player.hole_card_snap_ids) do
				ddnetpp.log_info("table join failed, freeing cid=" .. allocated_id .. " of the partially allocated hole card ids")
				ddnetpp.server.free_occupied_client_id(allocated_id)
			end
			return
		end
		table.insert(player.hole_card_snap_ids, snap_id)
	end

	-- first player to join the table will get the button
	if self:num_players() == 0 then
		player.is_button = true
	end

	self.players[client_id] = player
	self:send_chat(
		"'" .. ddnetpp.server.client_name(client_id) .. "' joined the table"
	)
end

---@param client_id integer
function Poker:leave_table(client_id)
	local player = self.players[client_id]
	for _, snap_id in pairs(player.hole_card_snap_ids) do
		ddnetpp.server.free_occupied_client_id(snap_id)
	end
	if self.state ~= GameState.END then
		self:send_chat(
			"'" .. ddnetpp.server.client_name(client_id) .. "' left the table"
		)
	end
	self.players[client_id] = nil
end
