Goof = {
	---@type BotName
	name = "goof",
	---@type Poker
	game = nil,
	---@type PokerPlayer
	player = nil,
}
Goof.__index = Goof

---@param client_id integer
---@param game Poker
---@return table
function Goof:new(client_id, game)
	local o = {}
	setmetatable(o, self)
	o.client_id = client_id
	o.game = game
	o.__index = self
	return o
end

---This has to be a function to look stuff up fresh
---so we can rig cards in the unit tests
---@return Card[]
function Goof:cards()
	---@type Card[]
	local cards = {}
	for _, card_str in ipairs(self.player.hole_cards) do
		table.insert(cards, str_to_card(card_str))
	end
	return cards
end

---At least one ace is good. The rest is unplayble omg omg
---@return boolean
function Goof:has_good_cards()
	for _, card in ipairs(self:cards()) do
		if card.rank >= 14 then
			return true
		end
	end
	return false
end

function Goof:check_or_call()
	local diff = self.game.pot_per_player - self.player.chips_paid_into_pot
	if diff == 0 then
		self.game:player_action(self.client_id, { action = "check" })
	else
		ddnetpp.send_chat_as(self.client_id, "I can't fold this monster of a hand")
		self.game:player_action(self.client_id, { action = "call" })
	end
end

function Goof:on_turn()
	if self.game.state == GameState.SHOWDOWN then
		ddnetpp.send_chat_as(self.client_id, "You are good")
		self.game:player_action(self.client_id, { action = "fold" })
		return
	end

	if self:has_good_cards() then
		self:check_or_call()
	else
		-- checking is not an option xd
		ddnetpp.send_chat_as(self.client_id, "I can't play this trash hand!")
		self.game:player_action(self.client_id, { action = "fold" })
	end
end
