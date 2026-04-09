-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃋🃊🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local eights_bad_kicker = find_best_hand(
	{ "🃖", "🂨" },
	{ "🃙", "🂸", "🃕", "🃄", "🃃" }
)
assert_eq("pair", eights_bad_kicker.name)
assert_eq("🂨🂸🃙🃖🃕", eights_bad_kicker.cards)
assert_eq("pair of eights", eights_bad_kicker.description)

local sevens_good_kicker = find_best_hand(
	{ "🂤", "🂧" },
	{ "🃊", "🂷", "🃛", "🃑", "🃃" }
)
assert_eq("pair", sevens_good_kicker.name)
assert_eq("🂧🂷🃑🃛🃊", sevens_good_kicker.cards)
assert_eq("pair of sevens", sevens_good_kicker.description)
assert_eq(10070007400, sevens_good_kicker.score)

assert_eq(true, eights_bad_kicker.score > sevens_good_kicker.score)
