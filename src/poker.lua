local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or "./"
end

require(script_path() .. "globals")
require(script_path() .. "card_converter")
require(script_path() .. "hand_rankings")
local snap = require(script_path() .. "snap")
require(script_path() .. "player")

---@class PlayerAction
---@field action string
---|"'check'"
---|"'bet'"
---|"'call'"
---|"'raise'"
---|"'fold'"
---@field amount? integer # Absolute amount in chip value
---@field announced? boolean # True if this action was already announced to other players, can stay false|nil longer for pre moves

---@class Seat
---@field number integer # Seats are numbered starting from 1, this is their unique identifier
---@field pos Position # Relative position to the table center
---@field client_id integer|nil # The player sitting on the seat

-- The main class representing an entire game state
-- there can be multiple instances if you want to play
-- multiple games at once
---@class Poker
Poker = {
	table = {
		pos = {
			x = 0,
			y = 0,
		},
		---@type Seat[]
		seats = {}
	},
	-- TODO: add buy in here
	prize_money = 10,
	pot = 0,
	start_stack = 50000,
	---The key is the seat number
	---@type PokerPlayer[]
	players = {},
	---@type string[]
	community_cards = {},
	---@type string[]
	deck = {},
	state = GameState.WAITING_FOR_PLAYERS,
	---@type integer[]
	community_card_snap_ids = {},
}

local function gamestate_to_str(state)
	if state == GameState.END then
		return "END"
	elseif state == GameState.ERROR then
		return "ERROR"
	elseif state == GameState.WAITING_FOR_PLAYERS then
		return "WAITING_FOR_PLAYERS"
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

function Poker:is_game_running()
	return self.state >= GameState.PRE_FLOP
end

---TODO: this can be extended to also take a client id as argument
---      and check how many times this ip address already washed out
---      to add a concept of maximum amount of chances
---      for now infinite rebuy is allowed as long as 4+ players are around
---
---If the game already progressed too far
---nobody can sit down at the table anymore to avoid
---swooping the win without playing most of the opponents
---@return boolean can_join # True if new players can still join the table
---@return string error_msg # Only set if can_join is false, error that can be shown to the attempting joiner
function Poker:can_still_join()
	if self.state == GameState.WAITING_FOR_PLAYERS then
		return true, ""
	end
	local num_playing = self:num_players_with_chips()
	if num_playing > 3 then
		return true, ""
	end
	return false, "Only " .. num_playing .. " players remaining, wait until the next game"
end

---@param amount integer
---@return Seat[] seats
local function build_seats(amount)
	---@type Seat[]
	local seats = {}
	for i = 1, amount do
		local seat = {
			number = i,
			pos = {
				x = -(amount / 2) + i * 2,
				y = 3
			},
			client_id = nil
		}
		table.insert(seats, seat)
	end
	return seats
end

---@param o Poker|nil
---@param table_pos Position
---@return Poker
function Poker:new(o, table_pos, num_seats)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.table = {}
	self.table.pos = table_pos or { x = 0, y = 0 }
	self.table.seats = build_seats(num_seats or 4)
	self.players = {}
	self.community_cards = {}
	self.community_card_snap_ids = {}
	self.next_to_act_snap_id = 0
	self.state = GameState.WAITING_FOR_PLAYERS
	self.deck = {}

	-- TODO: yikes split pots? how? where? when?
	self.pot = 0

	-- TODO: this variable feels super chaotic
	--       do we really need a total "pot" variable
	--       and a "pot_per_player" ?
	--       For now this helps me reason about it
	--       i assume there is a cleaner refactor
	--
	-- the "pot" is the amount of chips in the middle of the table
	-- and the "pot_per_player" is what every player that wants to continue
	-- playing this round has to have paid total
	-- this is not always pot/num_players because players might
	-- have folded or went all in with less
	-- or we are in the middle of the betting round and not all paid fully
	-- yet. This is also what this variable is for
	-- to figure out how much players still have to play to continue playing
	self.pot_per_player = 0
	return o
end

---@return Seat|nil seat # First free seat at the table or nil if the table is full
function Poker:find_free_seat()
	for _, seat in ipairs(self.table.seats) do
		if seat.client_id == nil then
			return seat
		end
	end
	return nil
end

---@param seat_number integer
function Poker:seat_open(seat_number)
	for _, seat in ipairs(self.table.seats) do
		if seat.number == seat_number then
			seat.client_id = nil
		end
	end
end

---@param client_id integer
---@return PokerPlayer|nil
function Poker:find_player(client_id)
	for _, player in pairs(self.players) do
		if client_id == player.client_id then
			return player
		end
	end
	return nil
end

---The full game state as a big multi line string
---this is just for debugging
---@return string gamestate
function Poker:state_to_str()
	local state =
		"gamestate: " .. gamestate_to_str(self.state) .. "\n" ..
		"pot: " .. self.pot

	for _, player in pairs(self.players) do

		local current_action = "(still has to act)"
		if player.action then
			current_action = player.action.action
		end

		local prev_actions = ""
		for _, action in ipairs(player.prev_actions) do
			prev_actions = prev_actions ..
				"  " .. action.action .. "\n"
		end

		state = state .. "\n" ..
			"player '" .. ddnetpp.server.client_name(player.client_id) .. "' " .. player.position.name .. "\n" ..
			" action: " .. current_action .. "\n" ..
			" prev actions:\n" .. prev_actions
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
	self.community_cards = {}
	self.deck = self:shuffled_deck()
	self.pot = 0

	for _, player in pairs(self.players) do
		player.hole_cards = self:deal_hole_cards()
		player.action = nil
		player.prev_actions = {}
		player.chips_paid_into_pot = 0
	end

	self:move_button()
	self:init_player_positions()

	local num_players = self:num_players()
	self:place_blinds(num_players)
	self.next_to_act_offset = self:first_offset_to_act()
end

function Poker:new_game()
	assert(self.state == GameState.WAITING_FOR_PLAYERS, "tried to start game but was already in state " .. self.state)
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
	for _, occupied_id in ipairs(self.community_card_snap_ids) do
		ddnetpp.server.free_occupied_client_id(occupied_id)
	end
	ddnetpp.snap.free_id(self.next_to_act_snap_id)
	for _, player in pairs(self.players) do
		self:leave_table(player.client_id)
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

function Poker:clear_all_actions_on_raise_or_bet()
	for _, player in pairs(self.players) do
		if player.action then
			table.insert(player.prev_actions, player.action)
		end
		player.action = nil
	end
end

---@param client_id integer
---@param action PlayerAction
function Poker:player_action(client_id, action)
	-- TODO: can the player be nil here? do we need to check that? Or is that on the callsite?
	local player = self:find_player(client_id)

	if not self:is_game_running() then
		ddnetpp.send_chat_target(client_id, "The game is not running yet")
		return
	end
	if player.action ~= nil then
		-- Premoves can still be changed
		-- as soon as it was announced it can not be changed anymore
		if player.action.announced then
			ddnetpp.send_chat_target(client_id, "wait until next round")
			return
		end
	end

	if #player.hole_cards == 0 then
		ddnetpp.send_chat_target(client_id, "Omg you already folded wait until next round")
		return
	end
	-- TODO: is chips == 0 enough? Or is there a need for an player.is_allin?
	if player.chips == 0 then
		ddnetpp.send_chat_target(client_id, "You are already all in, wait until next round")
		return
	end

	local diff = self.pot_per_player - player.chips_paid_into_pot
	if action.action == "check" then
		if diff > 0 then
			ddnetpp.send_chat_target(client_id, "You can not check. You need to pay at least " .. diff .. " chips to call.")
			return
		end
		player.action = action
	elseif action.action == "call" then
		if diff == 0 then
			ddnetpp.send_chat_target(client_id, "Nobody raised you. You can raise or check")
			return
		end

		-- TODO: should we do auto all in here? Or warn the player and require an intentional all in action
		--       with for example an /allin chat command
		if diff > player.chips then
			-- FIXME: this is breaking the game :D
			--        if players can never go all in ending the game will be fucked
			--        i guess you could still bleed out on blinds but bru.. xd
			ddnetpp.send_chat_target(client_id, "You do not have enough chips, and all in is not implemented yet xd")
			return
		end

		player.chips = player.chips - diff
		player.chips_paid_into_pot = player.chips_paid_into_pot + diff
		self.pot = self.pot + diff

		player.action = action
	elseif action.action == "raise" or action.action == "bet" then
		-- if facing a bet and raising by x
		-- the amount we actually put in to the pot is prev_bet+x
		-- not just x
		-- so raise amount is on top of the call amount

		if action.amount + diff > player.chips then
			-- TODO: offer a /allin command here
			ddnetpp.send_chat_target(client_id, "You do not have that many chips!")
			return
		end
		-- TODO: min bet size should be higher than 1
		if action.amount < 1 then
			-- TODO: better error message xd
			ddnetpp.send_chat_target(client_id, "bruder was")
			return
		end

		player.chips = player.chips - (action.amount + diff)
		player.chips_paid_into_pot = player.chips_paid_into_pot + (action.amount + diff)
		self.pot = self.pot + (action.amount + diff)
		self.pot_per_player = self.pot_per_player + action.amount

		-- we have to call print_betting_actions()
		-- here even tho it is called at the very end of the method too
		-- that is because clear_all_actions_on_raise_or_bet()
		-- messes with the player that has to act next
		-- so the raise might not be printed
		-- because the printer thinks we premoved
		--
		-- also we have to assign the action twice
		-- because we need the printer to know about it
		-- and also reset it after all actions got cleared
		-- this is a huge mess
		-- please clean this up after the tests are stable enough
		player.action = action
		self:print_betting_actions()

		-- TODO: should raise and bet ever be split?
		--       i think it does the exact same thing
		--       and user facing will be probably a /bet command either way
		--       otherwise its annoying ux
		--       user facing when announcing the actions we should still
		--       use "bet" or "raise" so players know better whats going
		--       on when seeing the action of others but ye whatever
		--       such minor detail that can be polished in the end
		--       shouldnt influence the code archticture much so for now its same
		self:clear_all_actions_on_raise_or_bet()
		player.action = action
	elseif action.action == "fold" then
		player.action = action

		-- TODO: should we do player.is_folded = true here instead?
		--       so we can show cards in the end smh?
		--       probably not but idk
		player.hole_cards = {}
	else
		assert(false, "Invalid betting action")
	end

	self:print_betting_actions()
	if not self:check_win_by_fold() then
		if self.next_to_act_offset == player.position.offset then
			self:compute_next_to_act()
		end
		self:check_next_state()
	end
end

---@alias WinType string
---|"'showdown'"
---|"'fold'"

---@return WinType win_type # What caused the win
---@return PokerPlayer[] winners # Who won, can be multiple if there is a split pot
function Poker:find_winners()
	local winners = {}
	---@type WinType
	local win_type = "showdown"
	if self:num_players_with_cards() == 1 then
		win_type = "fold"
		for _, player in pairs(self.players) do
			if #player.hole_cards > 0 then
				table.insert(winners, player)
				break
			end
		end
	else
		-- FIXME: IMPLEMENT A REAL SHOWDOWN

		local best_player = nil
		for _, player in pairs(self.players) do
			if #player.hole_cards > 0 then
				player.hand = find_best_hand(player.hole_cards, self.community_cards)
				if best_player == nil then
					best_player = player
				end
			end
		end
		table.insert(winners, best_player)

		-- TODO: insert multiple players if they all have the same top score


		-- assert(false, "winning on showdown is not implemented yet xd")
	end
	return win_type, winners
end

function Poker:round_winners_and_losers()
	-- TODO: kick ALL IN losers out of the table here

	local win_type, winners = self:find_winners()
	if #winners > 1 then
		assert(false, "split pot is not implemented yet. there are " ..  #winners .. " winnners")
	elseif #winners < 1 then
		assert(false, "nobody won???")
	end

	local winner = winners[1]
	winner.chips = winner.chips + self.pot

	ddnetpp.send_chat_target(winner.client_id, "You won the entire pot with " .. self.pot .. " chips in it!")

	if win_type == "showdown" then
		self:send_chat(
			"'" .. ddnetpp.server.client_name(winner.client_id) .. "' won with best hand " .. winner.hand.name .. " (" .. winner.hand.description .. ")"
		)
	else
		self:send_chat(
			"'" .. ddnetpp.server.client_name(winner.client_id) .. "' won because everyone folded"
		)
	end
end

function Poker:check_win_game()
	local chip_holders = self:players_with_chips()
	if #chip_holders < 1 then
		ddnetpp.log_error("no chip holders left? no idea what to do.. exploding!")
		assert(false, "no chip holders")
		return
	end
	if #chip_holders > 1 then
		return
	end

	-- TODO: actually send the prize money to the player xd

	local winner = chip_holders[1]
	self:send_chat(
		"'" .. ddnetpp.server.client_name(winner.client_id) .. "' " ..
		"won the entire game! And collected " .. self.prize_money .. " in prize money!"
	)
	self.state = GameState.END
end

---@return boolean won # True if someone won the game
function Poker:check_win_by_fold()
	if self:num_players_with_cards() == 1 then
		self:round_winners_and_losers()
		if self:check_win_game() then
			self:new_round()
		end
		return true
	end
	return false
end

function Poker:next_state()
	for _, player in pairs(self.players) do
		player.action = nil
		player.prev_actions = {}
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
		self:round_winners_and_losers()
		self:new_round()
		return
	end

	self.next_to_act_offset = self:first_offset_to_act()
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
	for _, player in pairs(self.players) do
		ddnetpp.send_chat_target(player.client_id, message)
	end
end

---TODO: wtf it this method and method name???
---
---This method will also return players that are
---already all in or folded use with caution
---If you want the first actual player that has to
---act this round use first_offset_to_act()
---@return integer button_offset
function Poker:_first_offset_to_act_stupid()
	if self.state == GameState.PRE_FLOP then
		local num_players = self:num_players()
		if num_players == 2 then
			return ButtonOffset.SMALL_BLIND
		elseif num_players == 3 then
			return ButtonOffset.BUTTON
		end
		return ButtonOffset.UTG
	end

	-- post flop is simple
	return ButtonOffset.SMALL_BLIND
end

---Find the first position that has to act at the beginning of this round.
---This is NOT the next player to act in the middle of the round.
---So pre flop that will be UTG if there are enough players
---and post flop this will be sb
---@return integer button_offset
function Poker:first_offset_to_act()
	local found_first = false
	local first = self:_first_offset_to_act_stupid()

	for _, player in ipairs(self:sort_players_by_position()) do
		local pos = player.position.offset
		if pos == first then
			found_first = true
		end
		if found_first then
			if #player.hole_cards > 0 and player.chips > 0 then
				return pos
			end
		end
	end
	for pos, player in ipairs(self:sort_players_by_position()) do
		if pos == first then
			break
		end
		if #player.hole_cards > 0 and player.chips > 0 then
			return pos
		end
	end

	assert(false, "failed to find first to act, no players with cards or chips left")
	return -1
end

---TODO: would it be useful to skip players here?
---      players that went all in or folded for example
---      not sure yet
---
---Sorts players by the position relative to the button
---The returned array will have the first player to act
---as first element and the second as second.
---So pre flop the returned array will start with utg,utg+1,..
---and post flop it will start with sb,bb,..
---@return PokerPlayer[] players
function Poker:sort_players_by_position()
	---@type PokerPlayer[]
	local players = {}

	local found_first = false
	local first_offset = self:_first_offset_to_act_stupid()

	for _, player in pairs(self.players) do
		if player.position.offset == first_offset then
			found_first = true
		end
		if found_first then
			table.insert(players, player)
		end
	end

	for _, player in pairs(self.players) do
		if player.position.offset == first_offset then
			break
		end
		table.insert(players, player)
	end

	return players
end

function Poker:print_betting_actions()
	for _, player in ipairs(self:sort_players_by_position()) do
		if player.action == nil then
			-- print("waiting for " .. player.client_id)
			-- print(self:state_to_str())
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

function Poker:render_broadcast_hud()
	local players_w_cards = 0
	for _, player in pairs(self.players) do
		if #player.hole_cards > 0 then
			players_w_cards = players_w_cards + 1
		end
	end

	-- TODO: "players with cards" sounds cring xd
	--       im sure there is a term for it
	--       i did not want to say just "players"
	--       maybe "players table:"
	--       and   "players in hand:"
	--       idk
	local hud =
		"pot: " .. self.pot .. "\n" ..
		"players with cards: " .. players_w_cards .. "\n"
	local align_left =
		"                                                   " ..
		"                                                   " ..
		"                                                   "
	for _, player in pairs(self.players) do
		local player_hud = "your chips: " .. player.chips
		ddnetpp.send_broadcast_target(
			player.client_id,
			hud .. player_hud .. align_left
		)
	end
end

function Poker:on_tick()
	if self.state == GameState.ERROR then
		return
	end
	if self.state == GameState.END then
		return
	end
	if self.state == GameState.WAITING_FOR_PLAYERS then
		if self:num_players_with_chips() > 3 then
			self:send_chat("enough players at the table, starting a new game!")
			self:new_game()
		end
		return
	end

	self:print_betting_actions()
	if ddnetpp.server.tick() % 10 == 0 then
		self:render_broadcast_hud()
	end
end

function Poker:on_snap(snapping_client)
	-- TODO: only snap to participants
	--       or maybe keep snapping to all? so others can watch

	for i, card in ipairs(self.community_cards) do
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

	local poker_player = self:find_player(snapping_client)
	local chr = ddnetpp.get_character(snapping_client)
	if poker_player ~= nil and chr ~= nil then
		local pos = chr:pos()
		pos.x = pos.x - 1.5
		pos.y = pos.y - 2
		for i, card in ipairs(poker_player.hole_cards) do
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
	if self:find_player(client_id) == nil then
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
---
---@return integer amount
function Poker:num_players()
	local num = 0
	for _ in pairs(self.players) do
		num = num + 1
	end
	return num
end

---@return integer num_players_with_cards
function Poker:num_players_with_cards()
	local num = 0
	for _, player in pairs(self.players) do
		if #player.hole_cards > 0 then
			num = num + 1
		end
	end
	return num
end

---@return integer num_players
function Poker:num_players_with_chips()
	local num = 0
	for _, player in pairs(self.players) do
		if player.chips > 0 then
			num = num + 1
		end
	end
	return num
end

---@return PokerPlayer[] players
function Poker:players_with_chips()
	local players = {}
	for _, player in ipairs(self.players) do
		if player.chips > 0 then
			table.insert(players, player)
		end
	end
	return players
end

---Not to be confused by sort_players_by_position()
---The seat order can only change if a new player joins
---the table or someone leaves the table
---The position changes every time the button moves.
function Poker:sort_players_by_seat()
end

---Removes player from the self.players array
---without creating a gap in the keys
---so it stays a proper lua array
---@param client_id integer
---@return PokerPlayer|nil removed_player # Removed player or nil if not found
function Poker:delete_player(client_id)
	for i = 1, #self.players do
		local player = self.players[i]
		if player.client_id == client_id then
			table.remove(self.players, i)
			self:sort_players_by_seat()
			return player
		end
	end
	return nil
end

---Add new player to the game
---@param player PokerPlayer
function Poker:add_player(player)
	table.insert(self.players, player)
	self:sort_players_by_seat()
end

---@param client_id integer
function Poker:join_table(client_id)
	if self.state == GameState.ERROR then
		ddnetpp.send_chat_target(client_id, "The game is in a failed state")
		return
	end
	local can_join, join_err = self:can_still_join()
	if not can_join then
		ddnetpp.send_chat_target(client_id, join_err)
		return
	end
	local player = PokerPlayer:new(client_id)

	local seat = self:find_free_seat()
	if seat == nil then
		ddnetpp.send_chat_target(client_id, "This poker table is already full")
		return
	end
	seat.client_id = client_id
	player.seat = seat.number

	for _ = 1, 2, 1 do
		local snap_id = nil
		snap_id = self:find_and_occupy_free_client_id()
		if snap_id == nil then
			ddnetpp.send_chat_target(client_id, "failed to join poker table, server is full")
			for _, allocated_id in ipairs(player.hole_card_snap_ids) do
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

	player.chips = self.start_stack
	self:add_player(player)
	self:send_chat(
		"'" .. ddnetpp.server.client_name(client_id) .. "' joined the table"
	)
end

---@param client_id integer
function Poker:leave_table(client_id)
	local player = self:find_player(client_id)
	if player == nil then
		ddnetpp.log_error("player not at the table tried to leave it!")
		return
	end
	for _, snap_id in ipairs(player.hole_card_snap_ids) do
		ddnetpp.server.free_occupied_client_id(snap_id)
	end
	if self.state ~= GameState.END then
		self:send_chat(
			"'" .. ddnetpp.server.client_name(client_id) .. "' left the table"
		)
	end
	self:seat_open(player.seat)
	self:delete_player(client_id)
	self:check_win_by_fold()
end
