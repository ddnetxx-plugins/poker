-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
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
assert_eq("🂧🂷🂢🃊🃛🃑", hand.cards)
assert_eq("pair of sevens", hand.description)
assert_eq(100737, hand.score)

