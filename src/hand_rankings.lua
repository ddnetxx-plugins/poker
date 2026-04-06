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
---@field cards string[] # The 5 cards used to build the hand something like "🂢🃂🂲🃑🃞", the amount is ALWAYS 5 no matter the hand

---Find one players best hand on showdown.
---Taking the players 2 hole cards and the 5 community cards
---and determining the highest possible combination
---
---@param hole_cards string[] # 2 cards in unicode format like {"🂢", ""🂲}
---@param community_cards string[] # 5 cards in unicode format like {"🃂", "🃞", "🃇", "🃑", "🂳"}
---@return HandRank best_hand
function find_best_hand(hole_cards, community_cards)
end

