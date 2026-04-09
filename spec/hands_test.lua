-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃋🃊🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local hand = find_best_hand(
	{ "🂢", "🂧" },
	{ "🃊", "🂷", "🃛", "🃑", "🂴" }
)
assert_eq("pair", hand.name)
assert_eq("🂧🂷🃑🃛🃊", hand.cards)
assert_eq("pair of sevens", hand.description)
assert_eq(10070007400, hand.score)

hand = find_best_hand(
	{ "🂤", "🂧" },
	{ "🃊", "🂷", "🃛", "🃑", "🃃" }
)
assert_eq("pair", hand.name)
assert_eq("🂧🂷🃑🃛🃊", hand.cards)
assert_eq("pair of sevens", hand.description)
assert_eq(10070007400, hand.score)

hand = find_best_hand(
	{ "🂤", "🃄" },
	{ "🃊", "🂷", "🃛", "🃑", "🂴" }
)
assert_eq("three of a kind", hand.name)
assert_eq("🂤🃄🂴🃑🃛", hand.cards)
assert_eq("set fours", hand.description)
assert_eq(30040006400, hand.score)

hand = find_best_hand(
	{ "🂤", "🂷" },
	{ "🃊", "🃄", "🃛", "🃑", "🂴" }
)
assert_eq("three of a kind", hand.name)
assert_eq("🂤🃄🂴🃑🃛", hand.cards)
assert_eq("trip fours", hand.description)
assert_eq(30040006400, hand.score)

hand = find_best_hand(
	{ "🂤", "🂺" },
	{ "🃄", "🃊", "🃛", "🃑", "🂢" }
)
assert_eq("two pair", hand.name)
assert_eq("🂺🃊🂤🃄🃑", hand.cards)
assert_eq("tens and fours", hand.description)
assert_eq(20100404200, hand.score)

hand = find_best_hand(
	{ "🂤", "🂺" },
	{ "🃄", "🃊", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂺🃊🃑", hand.cards)
assert_eq("jacks and tens", hand.description)
assert_eq(20111004200, hand.score)

hand = find_best_hand(
	{ "🂤", "🂩" },
	{ "🃄", "🂹", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂩🂹🃑", hand.cards)
assert_eq("jacks and nines", hand.description)
assert_eq(20110904200, hand.score)

hand = find_best_hand(
	{ "🂤", "🂨" },
	{ "🃄", "🂸", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂨🂸🃑", hand.cards)
assert_eq("jacks and eights", hand.description)
assert_eq(20110804200, hand.score)

hand = find_best_hand(
	{ "🂣", "🂩" },
	{ "🂳", "🂹", "🃛", "🃂", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂩🂹🂣", hand.cards)
assert_eq("jacks and nines", hand.description)
assert_eq(20110900900, hand.score)

hand = find_best_hand(
	{ "🃉", "🃑" },
	{ "🃂", "🂳", "🂤", "🂥", "🂦" }
)
assert_eq("straight", hand.name)
assert_eq("🃂🂳🂤🂥🂦", hand.cards)
assert_eq("six high straight", hand.description)
assert_eq(40060000000, hand.score)

hand = find_best_hand(
	{ "🃉", "🃑" },
	{ "🃂", "🂳", "🂤", "🂥", "🃎" }
)
assert_eq("straight", hand.name)
assert_eq("🃑🃂🂳🂤🂥", hand.cards)
assert_eq("ace low straight (wheel)", hand.description)
assert_eq(40050000000, hand.score)

hand = find_best_hand(
	{ "🃉", "🂡" },
	{ "🃂", "🂣", "🂨", "🂥", "🂮" }
)

assert_eq("flush", hand.name)
assert_eq("🂡🂮🂨🂥🂣", hand.cards)
assert_eq("ace high flush", hand.description)

hand = find_best_hand(
	{ "🃉", "🂡" },
	{ "🃂", "🂤", "🂨", "🂥", "🂮" }
)
-- 🂢🂣🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡

assert_eq("flush", hand.name)
assert_eq("🂡🂮🂨🂥🂤", hand.cards)
assert_eq("ace high flush", hand.description)

hand = find_best_hand(
	{ "🃉", "🂡" },
	{ "🃂", "🂤", "🂩", "🂥", "🂮" }
)

assert_eq("flush", hand.name)
assert_eq("🂡🂮🂩🂥🂤", hand.cards)
assert_eq("ace high flush", hand.description)

hand = find_best_hand(
	{ "🃉", "🂡" },
	{ "🃂", "🂧", "🂨", "🂦", "🂮" }
)

assert_eq("flush", hand.name)
assert_eq("🂡🂮🂨🂧🂦", hand.cards)
assert_eq("ace high flush", hand.description)
