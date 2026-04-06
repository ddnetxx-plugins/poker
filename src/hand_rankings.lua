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

---@param rank integer # 2-14
---@return string name # For example rank=7 is "sevens"
local function rank_to_name_plural(rank)
	local names = {
		"twos",
		"threes",
		"fours",
		"fives",
		"sixes",
		"sevens",
		"eigths",
		"nines",
		"tens",
		"jacks",
		"queens 💅💅", -- wtf is this?
		"kings",
		"aces"
	}
	return names[rank-1]
end

---@param card Card # Card to search for
---@param cards Card[] # Cards to search in
---@return boolean found # True if card is in cards
local function card_in_list(card, cards)
	for _, c in pairs(cards) do
		if c.rank == card.rank and c.suite == card.suite then
			return true
		end
	end
	return false
end

---@param winning_cards Card[] # 1-5 cards that formed the best hand
---@param all_cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return string five_best_cards
local function build_hand_string(winning_cards, all_cards)
	local remaning_cards = {}
	local best_cards = ""
	for _, card in pairs(all_cards) do
		if card_in_list(card, winning_cards) then
			best_cards = best_cards .. card_to_str(card)
		else
			table.insert(remaning_cards, card)
		end
	end

	-- FIXME: sort remaining cards by suite!!!

	local idx = 0
	for _ = #winning_cards, 5 do
		idx = idx + 1
		best_cards = best_cards .. card_to_str(remaning_cards[idx])
	end

	return best_cards
end

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
		description = "pair of " .. rank_to_name_plural(top_pair[1].rank),
		cards = build_hand_string(top_pair, cards)
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

