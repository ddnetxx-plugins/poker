local assert_eq = require("simple.assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃋🃊🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local queens_full_of_nines = find_best_hand(
	{ "🃉", "🃍" },
	{ "🃙", "🃝", "🂽", "🃛", "🂦" }
)
assert_eq("full house", queens_full_of_nines.name)
assert_eq("queens 💅💅 full of nines", queens_full_of_nines.description)
assert_eq("🃍🃝🂽🃉🃙", queens_full_of_nines.cards)
assert_eq(71209000000, queens_full_of_nines.score)

local kings_full_of_duces = find_best_hand(
	{ "🂢", "🂾" },
	{ "🂲", "🃎", "🃞", "🃛", "🂦" }
)
assert_eq("full house", kings_full_of_duces.name)
assert_eq("kings full of twos", kings_full_of_duces.description)
assert_eq("🂾🃎🃞🂢🂲", kings_full_of_duces.cards)
assert_eq(71302000000, kings_full_of_duces.score)

-- 3 kings and 3 duces
local kings_full_of_3duces = find_best_hand(
	{ "🂢", "🂾" },
	{ "🂲", "🃎", "🃞", "🃂", "🂦" }
)
assert_eq("full house", kings_full_of_3duces.name)

assert_eq(true, kings_full_of_duces.score > queens_full_of_nines.score)
assert_eq(true, kings_full_of_duces.score == kings_full_of_3duces.score)

