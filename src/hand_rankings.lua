---@alias HandRank string
---|"'high card'"
---|"'pair'"
---|"'two pair'"
---|"'three of a kind'"
---|"'straight'"
---|"'flush'"
---|"'full house'"
---|"'four of a kind'"
---|"'straight flush'"

---@class PokerHand
---@field name HandRank
---@field description string # More detailed version of name. Like "aces full of sevens", "spade flush 7 high", "straight king high"
---@field cards string # The 5 cards used to build the hand something like "🂢🃂🂲🃑🃞", the amount is ALWAYS 5 no matter the hand

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand best_high_card
local function find_high_card(cards)
	return {
		name = "high card",
		description = "MADE UP HAND OMG XD",
		cards = "🂢🃂🂲🃑🃞"
	}
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand|nil best_pair
local function find_pair(cards)
	-- the key is the hand rank
	-- and the value is the array of cards with that rank
	local buckets = {}
	for _, card in pairs(cards) do
		if buckets[card.rank] == nil then
			buckets[card.rank] = {}
		end
		table.insert(buckets[card.rank], card)
	end
	local top_pair = nil
	for _, bucket in pairs(buckets) do
		-- we wont find a pair if there is 3 of a kind
		-- or quads in the bucket
		-- which is fine
		if #bucket == 2 then
			if top_pair == nil then
				top_pair = bucket
			elseif top_pair[1].rank < bucket[1].rank then
				top_pair = bucket
			end
		end
	end
	if top_pair == nil then
		return nil
	end
	local hand = {
		name = "pair",
		description = "WAS BRUDER",
		cards = card_to_str(top_pair[1]) .. card_to_str(top_pair[2])
	}
	return hand
end

---Find one players best hand on showdown.
---Taking the players 2 hole cards and the 5 community cards
---and determining the highest possible combination
---
---@param hole_cards string[] # 2 cards in unicode format like {"🂢", "🂲"}
---@param community_cards string[] # 5 cards in unicode format like {"🃂", "🃞", "🃇", "🃑", "🂳"}
---@return PokerHand best_hand
function find_best_hand(hole_cards, community_cards)
	---@type Card[]
	local cards = {}
	for _, card in pairs(hole_cards) do
		table.insert(cards, str_to_card(card))
	end
	for _, card in pairs(community_cards) do
		table.insert(cards, str_to_card(card))
	end

	local pair = find_pair(cards)
	if pair then
		return pair
	end
	return find_high_card(cards)
end

