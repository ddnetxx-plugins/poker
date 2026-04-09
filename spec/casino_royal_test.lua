local assert_eq = require("simple.assert").assert_eq
require("../src/globals")
require("../src/card_converter")
require("../src/hand_rankings")

local player1 = find_best_hand(
	{ "🂮", "🂭" },
	{ "🂱", "🂨", "🂦", "🂤", "🂡" }
)
assert_eq("flush", player1.name)

local player2 = find_best_hand(
	{ "🃘", "🃈" },
	{ "🂱", "🂨", "🂦", "🂤", "🂡" }
)
assert_eq("three of a kind", player2.name) -- TODO: this is a full house

local le_chiffre = find_best_hand(
	{ "🃑", "🂶" },
	{ "🂱", "🂨", "🂦", "🂤", "🂡" }
)
assert_eq("three of a kind", le_chiffre.name) -- TODO: this is a full house

local james_bond = find_best_hand(
	{ "🂧", "🂥" },
	{ "🂱", "🂨", "🂦", "🂤", "🂡" }
)
assert_eq("straight flush", james_bond.name)

-- assert_eq(true, player1.score < player2.score)
-- assert_eq(true, player2.score < le_chiffre.score)
-- assert_eq(true, le_chiffre.score < james_bond.score)
