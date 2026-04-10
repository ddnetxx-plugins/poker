local assert_eq = require("simple.assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃋🃊🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local straight_6h = find_best_hand(
	{ "🃉", "🃑" },
	{ "🃂", "🂳", "🂤", "🂥", "🂦" }
)
assert_eq("straight", straight_6h.name)
assert_eq("🃂🂳🂤🂥🂦", straight_6h.cards)
assert_eq("six high straight", straight_6h.description)
assert_eq(50000000006, straight_6h.score)

local straight_5h = find_best_hand(
	{ "🃉", "🃑" },
	{ "🃂", "🂳", "🂤", "🂥", "🃙" }
)
assert_eq("straight", straight_5h.name)
assert_eq("🃑🃂🂳🂤🂥", straight_5h.cards)
assert_eq("ace low straight (wheel)", straight_5h.description)
assert_eq(50000000005, straight_5h.score)
