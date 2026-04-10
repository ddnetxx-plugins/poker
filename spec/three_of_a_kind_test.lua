-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃋🃊🃍🃁🃎
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local set4_ace_kicker = find_best_hand(
	{ "🂤", "🃄" },
	{ "🃊", "🂷", "🃛", "🃑", "🂴" }
)
assert_eq("three of a kind", set4_ace_kicker.name)
assert_eq("🂤🃄🂴🃑🃛", set4_ace_kicker.cards)
assert_eq("set fours", set4_ace_kicker.description)
assert_eq(40400001411, set4_ace_kicker.score)

local set4_king_kicker = find_best_hand(
	{ "🂤", "🃄" },
	{ "🃊", "🂷", "🃛", "🃎", "🂴" }
)
assert_eq("three of a kind", set4_king_kicker.name)
assert_eq("🂤🃄🂴🃎🃛", set4_king_kicker.cards)
assert_eq("set fours", set4_king_kicker.description)
assert_eq(40400001311, set4_king_kicker.score)

assert_eq(true, set4_ace_kicker.score > set4_king_kicker.score)
