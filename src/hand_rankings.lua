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
---@field score integer # The higher the better, can be used to compare hands

---@type HandRank[]
local HAND_RANKS = {
	"high card",
	"pair",
	"two pair",
	"three of a kind",
	"straight",
	"flush",
	"full house",
	"four of a kind",
	"straight flush",
}

---@param hand_rank HandRank
---@param cards Card[] # The winning cards
---@return integer score
local function hand_rank_to_score(hand_rank, cards)
	local idx = nil
	for i, rank in pairs(HAND_RANKS) do
		if hand_rank == rank then
			idx = i
			break
		end
	end
	assert(idx ~= nil, "unknown hand rank '" .. hand_rank .. "'")
	-- high card has a score of 0
	local score = (idx - 1) * 100000
	local bonus = 0
	if hand_rank == "high card" or hand_rank == "pair" then
		bonus = cards[1].rank * 100
	else
		-- the bonus is used to compare two hands of the same rank
		-- so for example which pair is higher a pair of sevens or a pair of nines
		-- it DOES NOT look at the kicker yet that value is computed somewhere else

		assert(false, "computing bonus score for hand '" .. hand_rank .. "' is not implemented")
	end
	return score + bonus
end

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
---@return integer score # The score gained by the remaining cards, not the full hand!
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

	local score = 0
	local idx = 0
	for _ = #winning_cards, 5 do
		idx = idx + 1
		best_cards = best_cards .. card_to_str(remaning_cards[idx])
		score = score + remaning_cards[idx].rank
	end

	-- FIXME: the remaining score is computed wrong
	--        first and second kicker are not of equal value!!
	--        if two players have the same pair and 2 different kicker
	--        we can not just add the 3 remaining cards including the 2 different kickers
	--        lets imagine this the board is 3365T
	--        and player A has: QJ
	--        and player B has: A2
	--        player B won because the ace is higher than the queen
	--        we can not just add all the ranks together
	--        because QJ is 11+12=23
	--        and A2 is only 14+2=16
	--        this might need an entire compare kicker mehtod?
	--        or can we smh put this in absolute scores without comparing?
	--        by giving the highest kicker a multiplier
	--        but how high is the multiplier? if there are two high cards
	--        on showdown we have 4 kickers?????? is that even a term?
	--        4 kickers???? xd

	return score, best_cards
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand best_high_card
local function find_high_card(cards)
	return {
		name = "high card",
		description = "MADE UP HAND OMG XD",
		cards = "🂢🃂🂲🃑🃞",
		score = 0
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

	local remaining_score, hand_str = build_hand_string(top_pair, cards)
	local hand = {
		name = "pair",
		description = "pair of " .. rank_to_name_plural(top_pair[1].rank),
		cards = hand_str
	}
	hand.score = hand_rank_to_score(hand.name, top_pair) + remaining_score
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

