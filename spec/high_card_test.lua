local assert_eq = require("simple.assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃋🃊🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local queen_high_10kicker = find_best_hand(
	{ "🂪", "🃍" },
	{ "🃙", "🂸", "🃕", "🃄", "🃃" }
)
assert_eq("high card", queen_high_10kicker.name)
assert_eq("🃍🂪🃙🂸🃕", queen_high_10kicker.cards)
assert_eq("queen high ten kicker", queen_high_10kicker.description)
assert_eq(01210090805, queen_high_10kicker.score)

local queen_high_9kicker = find_best_hand(
	{ "🃖", "🃍" },
	{ "🃙", "🂸", "🃕", "🃄", "🃃" }
)
assert_eq("high card", queen_high_9kicker.name)
assert_eq("🃍🃙🂸🃖🃕", queen_high_9kicker.cards)
assert_eq("queen high nine kicker", queen_high_9kicker.description)
assert_eq(01209080605, queen_high_9kicker.score)

assert_eq(true, queen_high_10kicker.score > queen_high_9kicker.score)
