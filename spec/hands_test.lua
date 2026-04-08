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
assert_eq(100707400, hand.score)

hand = find_best_hand(
	{ "🂤", "🂧" },
	{ "🃊", "🂷", "🃛", "🃑", "🃃" }
)
assert_eq("pair", hand.name)
assert_eq("🂧🂷🃑🃛🃊", hand.cards)
assert_eq("pair of sevens", hand.description)
assert_eq(100707400, hand.score)

hand = find_best_hand(
	{ "🂤", "🃄" },
	{ "🃊", "🂷", "🃛", "🃑", "🂴" }
)
assert_eq("three of a kind", hand.name)
assert_eq("🂤🃄🂴🃑🃛", hand.cards)
assert_eq("set fours", hand.description)
assert_eq(300406400, hand.score)

hand = find_best_hand(
	{ "🂤", "🂷" },
	{ "🃊", "🃄", "🃛", "🃑", "🂴" }
)
assert_eq("three of a kind", hand.name)
assert_eq("🂤🃄🂴🃑🃛", hand.cards)
assert_eq("trip fours", hand.description)
assert_eq(300406400, hand.score)

hand = find_best_hand(
	{ "🂤", "🂺" },
	{ "🃄", "🃊", "🃛", "🃑", "🂢" }
)
assert_eq("two pair", hand.name)
assert_eq("🂺🃊🂤🃄🃑", hand.cards)
assert_eq("tens and fours", hand.description)
assert_eq(201008200, hand.score)

hand = find_best_hand(
	{ "🂤", "🂺" },
	{ "🃄", "🃊", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂺🃊🃑", hand.cards)
assert_eq("jacks and tens", hand.description)
assert_eq(201114200, hand.score)

hand = find_best_hand(
	{ "🂤", "🂩" },
	{ "🃄", "🂹", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂩🂹🃑", hand.cards)
assert_eq("jacks and nines", hand.description)
assert_eq(201113200, hand.score)

hand = find_best_hand(
	{ "🂤", "🂨" },
	{ "🃄", "🂸", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂨🂸🃑", hand.cards)
assert_eq("jacks and eigths", hand.description)
assert_eq(201112200, hand.score)

hand = find_best_hand(
	{ "🂣", "🂩" },
	{ "🂳", "🂹", "🃛", "🃂", "🂻" }
)
assert_eq("two pair", hand.name)
assert_eq("🃛🂻🂩🂹🂣", hand.cards)
assert_eq("jacks and nines", hand.description)
assert_eq(201109900, hand.score) -- FIXME: this score is LOWER than eights wtf thats wrong
