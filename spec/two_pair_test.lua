-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃋🃊🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local jacks_and_nines = find_best_hand(
	{ "🂣", "🂩" },
	{ "🂳", "🂹", "🃛", "🃂", "🂻" }
)
assert_eq("two pair", jacks_and_nines.name)
assert_eq("🃛🂻🂩🂹🂣", jacks_and_nines.cards)
assert_eq("jacks and nines", jacks_and_nines.description)
assert_eq(20110900900, jacks_and_nines.score)

local jacks_and_eights = find_best_hand(
	{ "🂤", "🂨" },
	{ "🃄", "🂸", "🃛", "🃑", "🂻" }
)
assert_eq("two pair", jacks_and_eights.name)
assert_eq("🃛🂻🂨🂸🃑", jacks_and_eights.cards)
assert_eq("jacks and eights", jacks_and_eights.description)
assert_eq(20110804200, jacks_and_eights.score)

assert_eq(true, jacks_and_nines.score > jacks_and_eights.score)
