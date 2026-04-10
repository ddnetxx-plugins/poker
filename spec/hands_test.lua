-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local hand = find_best_hand(
	{ "🂢", "🂧" },
	{ "🃊", "🂷", "🃛", "🃑", "🂴" }
)
assert_eq("pair", hand.name)
assert_eq("🂧🂷🃑🃛🃊", hand.cards)
assert_eq("pair of sevens", hand.description)
assert_eq(20700141110, hand.score)

hand = find_best_hand(
	{ "🂤", "🂧" },
	{ "🃊", "🂷", "🃛", "🃑", "🃃" }
)
assert_eq("pair", hand.name)
assert_eq("🂧🂷🃑🃛🃊", hand.cards)
assert_eq("pair of sevens", hand.description)
assert_eq(20700141110, hand.score)

hand = find_best_hand(
	{ "🂤", "🃄" },
	{ "🃊", "🂷", "🃛", "🃑", "🂴" }
)
assert_eq("three of a kind", hand.name)
assert_eq("🂤🃄🂴🃑🃛", hand.cards)
assert_eq("set fours", hand.description)
assert_eq(40400001411, hand.score)

hand = find_best_hand(
	{ "🂤", "🂷" },
	{ "🃊", "🃄", "🃛", "🃑", "🂴" }
)
assert_eq("three of a kind", hand.name)
assert_eq("🂤🃄🂴🃑🃛", hand.cards)
assert_eq("trip fours", hand.description)
assert_eq(40400001411, hand.score)

hand = find_best_hand(
	{ "🂤", "🂺" },
	{ "🃄", "🃊", "🃛", "🃑", "🂢" }
)
assert_eq("two pair", hand.name)
assert_eq("🂺🃊🂤🃄🃑", hand.cards)
assert_eq("tens and fours", hand.description)
assert_eq(31004000014, hand.score)

hand = find_best_hand(
	{ "🂤", "🂺" },
	{ "🃄", "🃊", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂺🃊🃑", hand.cards)
assert_eq("jacks and tens", hand.description)
assert_eq(31110000014, hand.score)

hand = find_best_hand(
	{ "🂤", "🂩" },
	{ "🃄", "🂹", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂩🂹🃑", hand.cards)
assert_eq("jacks and nines", hand.description)
assert_eq(31109000014, hand.score)

hand = find_best_hand(
	{ "🂤", "🂨" },
	{ "🃄", "🂸", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂨🂸🃑", hand.cards)
assert_eq("jacks and eights", hand.description)
assert_eq(31108000014, hand.score)

hand = find_best_hand(
	{ "🂣", "🂩" },
	{ "🂳", "🂹", "🃛", "🃂", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂩🂹🂣", hand.cards)
assert_eq("jacks and nines", hand.description)
assert_eq(31109000003, hand.score)

hand = find_best_hand(
	{ "🃉", "🃑" },
	{ "🃂", "🂳", "🂤", "🂥", "🂦" }
)
assert_eq("straight", hand.name)
assert_eq("🃂🂳🂤🂥🂦", hand.cards)
assert_eq("six high straight", hand.description)
assert_eq(50000000006, hand.score)

hand = find_best_hand(
	{ "🃉", "🃑" },
	{ "🃂", "🂳", "🂤", "🂥", "🃎" }
)
assert_eq("straight", hand.name)
assert_eq("🃑🃂🂳🂤🂥", hand.cards)
assert_eq("ace low straight (wheel)", hand.description)
assert_eq(50000000005, hand.score)

hand = find_best_hand(
	{ "🃉", "🂡" },
	{ "🃂", "🂣", "🂨", "🂥", "🂮" }
)

assert_eq("flush", hand.name)
assert_eq("🂡🂮🂨🂥🂣", hand.cards)
assert_eq("ace high flush", hand.description)
assert_eq(61413080503, hand.score)

hand = find_best_hand(
	{ "🃉", "🂡" },
	{ "🃂", "🂤", "🂨", "🂥", "🂮" }
)

assert_eq("flush", hand.name)
assert_eq("🂡🂮🂨🂥🂤", hand.cards)
assert_eq("ace high flush", hand.description)
assert_eq(61413080504, hand.score)

hand = find_best_hand(
	{ "🃉", "🂡" },
	{ "🃂", "🂤", "🂩", "🂥", "🂮" }
)

assert_eq("flush", hand.name)
assert_eq("🂡🂮🂩🂥🂤", hand.cards)
assert_eq("ace high flush", hand.description)
assert_eq(61413090504, hand.score)

hand = find_best_hand(
	{ "🃉", "🂡" },
	{ "🃂", "🂧", "🂨", "🂦", "🂮" }
)

assert_eq("flush", hand.name)
assert_eq("🂡🂮🂨🂧🂦", hand.cards)
assert_eq("ace high flush", hand.description)
assert_eq(61413080706, hand.score)
