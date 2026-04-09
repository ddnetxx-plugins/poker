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

---Which suit is the strongest
---source https://www.mypokercoaching.com/poker-suit-rankings/
---
---Spades=4
---Hearts=3
---Diamonds=2
---Clubs=1
---@param suit Suit
---@return integer rank # The higher the better
function suit_to_rank(suit)
	if suit == "spades" then
		return 4
	elseif suit == "hearts" then
		return 3
	elseif suit == "diamonds" then
		return 2
	elseif suit == "clubs" then
		return 1
	end
	assert(false, "unknown suit '" .. suit .. "'")
	return 0
end

---@param card Card
---@return string card_str # Something like "🃔"
function card_to_str(card)
	local y = 4 - suit_to_rank(card.suit)
	local idx = 13 * y + card.rank - 1
	return CARDS[idx]
end

---@param cards Card[]
---@return string cards_str # Something like "🂸🃔"
function cards_to_str(cards)
	local result = ""
	for _, card in ipairs(cards) do
		result = result .. card_to_str(card)
	end
	return result
end
