local assert_eq = require("simple.assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃋🃊🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local sf_6h = find_best_hand(
	{ "🃉", "🃍" },
	{ "🂢", "🂣", "🂤", "🂥", "🂦" }
)
assert_eq("straight flush", sf_6h.name)

-- this is tricky because there is a 6 high straight
-- and a 5 high straight flush
local sf_wheel = find_best_hand(
	{ "🃉", "🂡" },
	{ "🂢", "🂣", "🂤", "🂥", "🂶" }
)
assert_eq("straight flush", sf_wheel.name)
assert_eq("🂡🂢🂣🂤🂥", sf_wheel.cards)
assert_eq(90000000005, sf_wheel.score)

-- k high straight flush and ace high straight
local sf_kh = find_best_hand(
	{ "🃉", "🂩" },
	{ "🂪", "🂫", "🂭", "🂮", "🃁" }
)
assert_eq("straight flush", sf_kh.name)
assert_eq("🂩🂪🂫🂭🂮", sf_kh.cards)
assert_eq("king high straight flush", sf_kh.description)

local royal_flush = find_best_hand(
	{ "🃉", "🂩" },
	{ "🂪", "🂫", "🂭", "🂮", "🂡" }
)
assert_eq("straight flush", royal_flush.name)
assert_eq("🂪🂫🂭🂮🂡", royal_flush.cards)
assert_eq("royal flush", royal_flush.description)
