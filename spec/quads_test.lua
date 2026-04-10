local assert_eq = require("simple.assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃝🃛🃞🃑

local quad_nines = find_best_hand(
	{ "🃉", "🃍" },
	{ "🃙", "🂹", "🂽", "🂩", "🂦" }
)
assert_eq("four of a kind", quad_nines.name)
assert_eq("quad nines", quad_nines.description)
assert_eq("🃉🃙🂹🂩🂽", quad_nines.cards)
assert_eq(80900000012, quad_nines.score)

local quad_tens_queen_kicker = find_best_hand(
	{ "🂪", "🃍" },
	{ "🂺", "🃊", "🂽", "🃚", "🂦" }
)
assert_eq("four of a kind", quad_tens_queen_kicker.name)
assert_eq("quad tens", quad_tens_queen_kicker.description)
assert_eq("🂪🂺🃊🃚🂽", quad_tens_queen_kicker.cards)
assert_eq(81000000012, quad_tens_queen_kicker.score)

local quad_tens_ace_kicker = find_best_hand(
	{ "🂪", "🂡" },
	{ "🂺", "🃊", "🂽", "🃚", "🂦" }
)
assert_eq("four of a kind", quad_tens_ace_kicker.name)
assert_eq("quad tens", quad_tens_ace_kicker.description)
assert_eq("🂪🂺🃊🃚🂡", quad_tens_ace_kicker.cards)
assert_eq(81000000014, quad_tens_ace_kicker.score)

assert_eq(true, quad_tens_ace_kicker.score > quad_tens_queen_kicker.score)
assert_eq(true, quad_tens_queen_kicker.score > quad_nines.score)
