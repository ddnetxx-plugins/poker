---@class Card
---@field suit Suit
---@field rank integer # 2-14 inclusive 2=2 A=14

---@param card_str string # Something like "🃔" only one card at a time
---@return Card
function str_to_card(card_str)
	local idx = nil
	for i, card in pairs(CARDS) do
		if card == card_str then
			idx = i
			break
		end
	end
	assert(idx ~= nil, "card '" .. card_str .. "' not found")

	local y = math.floor((idx-1) / 13) + 1
	local x = math.floor((idx-1) % 13) + 2

	return {
		suit = SUITS[y],
		rank = x
	}
end

---@param card Card
---@return string card_str # Something like "🃔"
function card_to_str(card)
	local y = 0
	if card.suit == 'spades' then
		y = 0
	elseif card.suit == 'hearts' then
		y = 1
	elseif card.suit == 'diamonds' then
		y = 2
	elseif card.suit == 'clubs' then
		y = 3
	else
		assert(false, "unknown suit '" .. card.suit .. "'")
	end

	local idx = 13 * y + card.rank - 1
	return CARDS[idx]
end
