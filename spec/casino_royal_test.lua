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
assert_eq("full house", player2.name)
assert_eq("eights full of aces", player2.description)

local le_chiffre = find_best_hand(
	{ "🃑", "🂶" },
	{ "🂱", "🂨", "🂦", "🂤", "🂡" }
)
assert_eq("full house", le_chiffre.name)
assert_eq("aces full of sixes", le_chiffre.description)

local james_bond = find_best_hand(
	{ "🂧", "🂥" },
	{ "🂱", "🂨", "🂦", "🂤", "🂡" }
)
assert_eq("straight flush", james_bond.name)

assert_eq(true, player1.score < player2.score)
assert_eq(true, player2.score < le_chiffre.score)
assert_eq(true, le_chiffre.score < james_bond.score)
