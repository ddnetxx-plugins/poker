-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃑🃞

local hole_ak = { "🂡", "🂮" }
local hole_s3 = { "🂢", "🂣" }
local hole_fives = { "🂵", "🃅" }
local hole_jacks = { "🃋", "🃛" }

local board_quads = { "🂤", "🂴", "🃄", "🃔", "🃕" }

local hand = find_best_hand(hole_ak, board_quads)
assert_eq("four of a kind", hand.name)
assert_eq(80400000014, hand.score)

hand = find_best_hand(hole_s3, board_quads)
assert_eq("four of a kind", hand.name)
assert_eq(80400000005, hand.score)

hand = find_best_hand(hole_fives, board_quads)
assert_eq("four of a kind", hand.name)
assert_eq(80400000005, hand.score)

hand = find_best_hand(hole_jacks, board_quads)
assert_eq("four of a kind", hand.name)
assert_eq(80400000011, hand.score)
