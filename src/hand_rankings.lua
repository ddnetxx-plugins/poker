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

-- poker hand score format
-- it is always 11 digits
-- where the first digit is the hand rank (high card, pair, ..)
-- the second 2 digits is the rank of the most valuable card
-- that is the high card or the pair or the 3 cards of the full house
-- or the stronger pair of two pair
-- the next two digits are the rank of the weaker part of the hand rank
-- so the lower pair in two pair or the 2 matching cards in full house
-- this value is 00 for high card, pair, quads, three of a kind
--
-- flush, straight and straight flush are a bit special
-- straight and straight flash contain the highest ranking card as last 2 digits
-- and the remaining digits are 00
-- in a flush all 5 cards are listed ordered by rank
--
-- the 11 digit number can be split into these segments:
--
--                x aa bb k1 k2 k3
--                ^ ^  ^  ^  ^  ^
--                | |  |  |  |  |
--                | |  |  |  | 3rd best kicker
--                | |  |  |  | in a straight this is the highest card
--                | |  |  |  | and aa,bb,k1,k2 are all 00
--                | |  |  |  |
--                | |  |  | 2nd best kicker
--                | |  |  |
--        hand rank |  | best kicker
--     0=high card  |  |
--     1=pair       | second most valuable rank
--     2=two pair   | but never the kicker!
--     ...          | this is the weaker pairs rank for two pair
--                  | or the 2 matching cards of the full house
--                  | ----
--                  | in a flush this is the highest card of the flush
--                  |
--                  |
--            most valuable rank
--            so for high card ace
--            this is 14 for high card
--            ten this is 10
--            and for a pair of sevens this
--            is 07
--            for a two pair this is the number
--            of the stronger pair
--            ----
--            in a flush this is the highest card of the flush
--
-- here an example of 🃍🂪🃙🂸🃕 queen high with 10 kicker
--
--                01210090805
--                ^^ ^ ^ ^ ^
--        high card| | | | 05=5 4th kicker
--                 | | | 08=8 3rd kicker
--                 | | 09=9 2nd kicker
--                 | 10=ten kicker
--                 12=queen
--
-- the kickers are right aligned
-- there is a padding of zeros between the cards
-- that make the hand an the kickers

---@param hand_rank HandRank
---@param cards Card[] # The winning cards
---@return integer score
local function hand_rank_to_score(hand_rank, cards)
	local idx = nil
	for i, rank in ipairs(HAND_RANKS) do
		if hand_rank == rank then
			idx = i
			break
		end
	end
	assert(idx ~= nil, "unknown hand rank '" .. hand_rank .. "'")
	-- high card has a score of 0
	local score = (idx - 1) * 10000000000
	local bonus = 0
	-- these ranks are simple all cards are the same
	-- so pick any and use that rank
	-- more complicated is to determine which rank to give a full house where there is multiple different cards
	-- or a straight/flush where we have to find the highest card
	if hand_rank == "high card" or hand_rank == "pair" or hand_rank == "three of a kind" or hand_rank == "four of a kind" then
		-- there is only card we rank by
		-- so we use the highest possible index in the score number
		-- which is the second and third digit
		-- the first digit is the hand rank (pair, three of a kind, and so on..)
		-- and the second and third hold the card value from 02 (duce) to 14 (ace)
		-- and all the remaining digits are for kickers
		bonus = cards[1].rank * 100000000
	elseif hand_rank == "two pair" then
		bonus = (cards[1].rank * 100000000) + (cards[3].rank * 1000000)
	elseif hand_rank == "straight" or hand_rank == "straight flush" then
		if cards[5].rank == 14 then
			if cards[4].rank == 2 then
				-- wheel
				
			else
				-- nut straight
			end
		else
			bonus = cards[5].rank
		end
	elseif hand_rank == "flush" then
		-- the flush implements the bonus in place
		-- which is a bit of a mess xd
		-- should be cleaned up
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
		"eights",
		"nines",
		"tens",
		"jacks",
		"queens 💅💅", -- wtf is this?
		"kings",
		"aces"
	}
	return names[rank-1]
end

---@param rank integer # 2-14
---@return string name # For example rank=7 is "seven"
local function rank_to_name(rank)
	local names = {
		"two",
		"three",
		"four",
		"five",
		"six",
		"seven",
		"eight",
		"nine",
		"ten",
		"jack",
		"queen",
		"king",
		"ace"
	}
	return names[rank-1]
end

---@param card Card # Card to search for
---@param cards Card[] # Cards to search in
---@return boolean found # True if card is in cards
local function card_in_list(card, cards)
	for _, c in ipairs(cards) do
		if c.rank == card.rank and c.suit == card.suit then
			return true
		end
	end
	return false
end

---@return integer|nil index # Array index in cards where card is located
local function find_card_index_in_list(card, cards)
	for idx, c in ipairs(cards) do
		if c.rank == card.rank and c.suit == card.suit then
			return idx
		end
	end
	return nil
end

---@param winning_cards Card[] # 1-5 cards that formed the best hand
---@param all_cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return integer score # The score gained by the remaining cards, not the full hand!
---@return string five_best_cards
local function build_hand_string(winning_cards, all_cards)
	local remaining_cards = {}
	local best_cards = ""

	for _, card in ipairs(all_cards) do
		table.insert(remaining_cards, card)
	end

	for _, card in ipairs(winning_cards) do
		local idx = find_card_index_in_list(card, remaining_cards)
		if idx then
			table.remove(remaining_cards, idx)
		end
		best_cards = best_cards .. card_to_str(card)
	end

	-- only pick the best remaining cards
	table.sort(remaining_cards, function(a, b)
		if a.rank == b.rank then
			-- also sort by suit for maximum consistency
			-- not that it affects the score
			-- but if we would want to offer a option
			-- for the suit ranking this could be done here too
			-- according to https://www.mypokercoaching.com/poker-suit-rankings/
			-- there is a order from strongest to weakest:
			-- - spades
			-- - hearts
			-- - diamonds
			-- - clubs
			return suit_to_rank(a.suit) > suit_to_rank(b.suit)
		end
		return a.rank > b.rank
	end)

	local score = 0
	local idx = 0
	local num_kickers = 5 - #winning_cards
	for _ = #winning_cards, 4 do
		idx = idx + 1
		best_cards = best_cards .. card_to_str(remaining_cards[idx])
		local position_value = math.floor(100 ^ (num_kickers - idx))
		local kicker_score = (remaining_cards[idx].rank * position_value)
		score = score + kicker_score
	end

	-- first and second kicker are not of equal value!!
	-- if two players have the same pair and 2 different kicker
	-- we can not just add the 3 remaining cards including the 2 different kickers
	-- lets imagine this the board is 3365T
	-- and player A has: QJ
	-- and player B has: A2
	-- player B won because the ace is higher than the queen
	-- we can not just add all the ranks together
	-- because QJ is 11+12=23
	-- and A2 is only 14+2=16
	-- this might need an entire compare kicker method?
	-- or can we smh put this in absolute scores without comparing?
	-- by giving the highest kicker a multiplier
	-- but how high is the multiplier? if there are two high cards
	-- on showdown we have 4 kickers?????? is that even a term?
	-- 4 kickers???? xd

	return score, best_cards
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand best_high_card
local function find_high_card(cards)
	local sorted = {}
	for _, card in ipairs(cards) do
		table.insert(sorted, card)
	end
	table.sort(sorted, function (a, b)
		return a.rank > b.rank
	end)
	sorted[6] = nil
	local score, _ = build_hand_string(sorted[1], sorted)

	local desc =
		rank_to_name(sorted[1].rank) .. " high " ..
		rank_to_name(sorted[2].rank) .. " kicker"

	return {
		name = "high card",
		description = desc,
		cards = cards_to_str(sorted),
		score = score
	}
end

function sortUniqueByKey(arr, keyFunc)
    keyFunc = keyFunc or function(x) return x end
    local seen = {}
    local unique = {}
    for _, item in ipairs(arr) do
        local key = keyFunc(item)
        if not seen[key] then
            seen[key] = true
            table.insert(unique, item)
        end
    end
    table.sort(unique, function(a, b)
        return keyFunc(a) < keyFunc(b)
    end)
    return unique
end

local function reverse_arr(arr)
    local n = #arr
    for i = 1, math.floor(n / 2) do
        arr[i], arr[n - i + 1] = arr[n - i + 1], arr[i]
    end
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand|nil best_flush
local function find_flush(cards)
	---Buckets of suits
	---@type Card[][]
	local buckets = {}
	for _, card in ipairs(cards) do
		-- print("card=" .. card_to_str(card) .. " suit=" .. card.suit)
		if buckets[card.suit] == nil then
			buckets[card.suit] = {}
		end
		table.insert(buckets[card.suit], card)
	end
	---@type Card[]
	local flush = {}
	for _, bucket in pairs(buckets) do
		-- print(" " .. _ .. " with cards=" .. #bucket)
		if #bucket >= 5 then
			-- there can at least only be one flush
			-- in 7 cards so we break here
			flush = bucket
			break
		end
	end
	if #flush < 5 then
		return nil
	end
	table.sort(flush, function(a, b)
		return a.rank > b.rank
	end)
	-- truncate too long flush
	flush[6] = nil

	-- this is a similar logic to computing
	-- the kicker score
	-- all the card ranks in the flush could be seen
	-- as "kicker" where the highest different kicker wins
	-- so we sum them all up multiplying the position by 100
	-- this multiplier makes sure that multiple weak kicker
	-- can not outrank one stronger kicker
	local score = 0
	for i, card in ipairs(flush) do
		local position_value = math.floor(100 ^ (5 - i))
		local card_score = (card.rank * position_value)
		score = score + card_score
	end

	local hand = {
		name = "flush",
		description = rank_to_name(flush[1].rank) .. " high flush",
		cards = cards_to_str(flush),
		score = score,
	}
	hand.score = hand.score + hand_rank_to_score(hand.name, flush)
	return hand
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand|nil best_straight
local function find_straight(cards)
	local sorted = {}
	-- remove dupes because they dont help the straight
	local seen = {}
	for _, card in ipairs(cards) do
		if not seen[card.rank] then
			seen[card.rank] = true
			table.insert(sorted, card)
		end
	end
	-- then sort best card first
	table.sort(sorted, function(a, b)
		return a.rank > b.rank
	end)
	-- if the first card is an ace we copy it to the end for the wheel
	local first = sorted[1]
	if first.rank == 14 then
		table.insert(sorted, first)
	end

	-- no point in searching for a straight in 4 or less cards
	if #sorted < 5 then
		return nil
	end

	local straight = {}
	for idx, card in ipairs(sorted) do
		local prev_card = sorted[idx-1]
		if prev_card == nil then
			table.insert(straight, card)
		else
			if card.rank + 1 == prev_card.rank or card.rank == 14 and prev_card.rank == 2 then
				table.insert(straight, card)
				if #straight == 5 then
					break
				end
			else
				straight = {}
				table.insert(straight, card)
			end
		end
	end

	if #straight ~= 5 then
		return nil
	end

	reverse_arr(straight)

	local hand_str = ""
	for _, card in ipairs(straight) do
		hand_str = hand_str .. card_to_str(card)
	end

	local desc = rank_to_name(straight[5].rank) .. " high straight"
	if straight[1].rank == 14 then
		desc = "ace low straight (wheel)"
	end

	local hand = {
		name = "straight",
		description = desc,
		cards = hand_str,
	}
	hand.score = hand_rank_to_score(hand.name, straight)
	return hand
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand|nil straight_flush
local function find_straight_flush(cards)

	-- TODO: fix the performance here lmao
	--       this is the worst possible way to do it
	--       i just wanted to use the already existing flush and straight
	--       finder here to progress faster
	--       ----
	--       also move this method to the top to be ordered
	--       by rank once the dependency on find_flush() and find_straight()
	--       is removed

	local _flush = find_flush(cards)
	-- no straight flush without flush :D
	if _flush == nil then
		return nil
	end
	local suit = str_to_card(string.sub(_flush.cards, 1, 4)).suit

	local sorted = {}
	-- filter out other suits than the flush
	for _, card in ipairs(cards) do
		if card.suit == suit then
			table.insert(sorted, card)
		end
	end
	-- then sort best card first
	table.sort(sorted, function(a, b)
		return a.rank > b.rank
	end)
	-- if the first card is an ace we copy it to the end for the wheel
	local first = sorted[1]
	if first.rank == 14 then
		table.insert(sorted, first)
	end

	-- no point in searching for a straight in 4 or less cards
	if #sorted < 5 then
		return nil
	end

	local straight = {}
	for idx, card in ipairs(sorted) do
		local prev_card = sorted[idx-1]
		if prev_card == nil then
			table.insert(straight, card)
		else
			if card.rank + 1 == prev_card.rank or card.rank == 14 and prev_card.rank == 2 then
				table.insert(straight, card)
				if #straight == 5 then
					break
				end
			else
				straight = {}
				table.insert(straight, card)
			end
		end
	end

	if #straight ~= 5 then
		return nil
	end

	reverse_arr(straight)

	local desc = rank_to_name(straight[5].rank) .. " high straight flush"
	if straight[5].rank == 14 then
		desc = "royal flush"
	end

	local hand = {
		name = "straight flush",
		description = desc,
		cards = cards_to_str(straight),
	}
	hand.score = hand_rank_to_score(hand.name, straight)
	return hand
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand|nil best_three_of_a_kind
local function find_three_of_a_kind(cards)
	-- the key is the hand rank
	-- and the value is the array of cards with that rank
	local buckets = {}
	for _, card in ipairs(cards) do
		if buckets[card.rank] == nil then
			buckets[card.rank] = {}
		end
		table.insert(buckets[card.rank], card)
	end
	local highest_three = nil
	for _, bucket in pairs(buckets) do
		-- we wont find a pair or quads here which is bad for performance
		-- but helps me think about the ranking better
		-- ideally pair,three of a kind and quads will be merged
		-- once there are good tests and a first working version
		if #bucket == 3 then
			if highest_three == nil then
				highest_three = bucket
			elseif highest_three[1].rank < bucket[1].rank then
				highest_three = bucket
			end
		end
	end
	if highest_three == nil then
		return nil
	end

	local rank = highest_three[1].rank
	local card_names = rank_to_name_plural(rank)
	local desc = "three of a kind"

	-- hole cards are first in the array
	-- if they match the three of a kind
	-- it is a set with pocket pair
	if cards[1].rank == rank and cards[2].rank == rank then
		desc = "set " .. card_names
	elseif cards[1].rank == rank or cards[2].rank == rank then
		desc = "trip " .. card_names
	else
		desc = "trip " .. card_names .. " on the board"
	end

	local remaining_score, hand_str = build_hand_string(highest_three, cards)
	local hand = {
		name = "three of a kind",
		description = desc,
		cards = hand_str
	}
	hand.score = hand_rank_to_score(hand.name, highest_three) + remaining_score
	return hand
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand|nil best_two_pair
local function find_two_pair(cards)
	-- the key is the hand rank
	-- and the value is the array of cards with that rank
	local buckets = {}
	for _, card in ipairs(cards) do
		if buckets[card.rank] == nil then
			buckets[card.rank] = {}
		end
		table.insert(buckets[card.rank], card)
	end
	local top_pair = nil
	for _, bucket in pairs(buckets) do
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
	local second_pair = nil
	for _, bucket in pairs(buckets) do
		-- this won't find a full house
		-- which makes the code easier to reason about for now
		-- but should be refactored later
		if #bucket == 2 and bucket[1].rank ~= top_pair[1].rank then
			if second_pair == nil then
				second_pair = bucket
			elseif second_pair[1].rank < bucket[1].rank then
				second_pair = bucket
			end
		end
	end
	if second_pair == nil then
		return nil
	end

	local two_pair = top_pair
	for _, card in ipairs(second_pair) do
		table.insert(two_pair, card)
	end

	local remaining_score, hand_str = build_hand_string(two_pair, cards)
	local hand = {
		name = "two pair",
		description = rank_to_name_plural(top_pair[1].rank) .. " and " .. rank_to_name_plural(second_pair[1].rank),
		cards = hand_str
	}
	hand.score = hand_rank_to_score(hand.name, two_pair) + remaining_score
	return hand
end

---@param cards Card[] # 7 cards consisting of 5 community and 2 hole cards
---@return PokerHand|nil best_pair
local function find_pair(cards)
	-- the key is the hand rank
	-- and the value is the array of cards with that rank
	local buckets = {}
	for _, card in ipairs(cards) do
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

	-- TODO: should cards be sorted by rank and suit?
	--       so the final hand string is consistent?
	--       but we need the two hole cards first so
	--       three of a kind can know if its set or trips
	--       idk bit messy
	--       do we evene need a deterministic card order in the hand?
	--       it affects the unit tests and nothing else i think

	for _, card in ipairs(hole_cards) do
		table.insert(cards, str_to_card(card))
	end
	for _, card in ipairs(community_cards) do
		table.insert(cards, str_to_card(card))
	end

	local finders = {
		find_straight_flush,
		find_flush,
		find_straight,
		find_three_of_a_kind,
		find_two_pair,
		find_pair,
		find_high_card,
	}

	for _, finder in ipairs(finders) do
		local hand = finder(cards)
		if hand then
			return hand
		end
	end

	assert(false, "no hand found")
end

