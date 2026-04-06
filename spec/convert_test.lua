-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/card_converter")

assert_eq("🃑", card_to_str({ suite = "clubs", rank = 14 }))
assert_eq("🂢", card_to_str({ suite = "spades", rank = 2 }))
assert_eq("🂴", card_to_str({ suite = "hearts", rank = 4 }))
assert_eq("🃄", card_to_str({ suite = "diamonds", rank = 4 }))
assert_eq("🃔", card_to_str({ suite = "clubs", rank = 4 }))
assert_eq("🃑", card_to_str({ suite = "clubs", rank = 14 }))
assert_eq("🃒", card_to_str({ suite = "clubs", rank = 2 }))

assert_eq(2, str_to_card("🃒").rank)
assert_eq("clubs", str_to_card("🃒").suite)

assert_eq(4, str_to_card("🃔").rank)
assert_eq("clubs", str_to_card("🃔").suite)

assert_eq(14, str_to_card("🃑").rank)
assert_eq("clubs", str_to_card("🃑").suite)

assert_eq(2, str_to_card("🃂").rank)
assert_eq("diamonds", str_to_card("🃂").suite)

assert_eq(4, str_to_card("🃄").rank)
assert_eq("diamonds", str_to_card("🃄").suite)

assert_eq(14, str_to_card("🃁").rank)
assert_eq("diamonds", str_to_card("🃁").suite)

assert_eq(14, str_to_card("🂱").rank)
assert_eq("hearts", str_to_card("🂱").suite)

assert_eq(2, str_to_card("🂲").rank)
assert_eq("hearts", str_to_card("🂲").suite)

assert_eq(2, str_to_card("🂢").rank)
assert_eq("spades", str_to_card("🂢").suite)

assert_eq(6, str_to_card("🂦").rank)
assert_eq("spades", str_to_card("🂦").suite)

assert_eq(14, str_to_card("🂡").rank)
assert_eq("spades", str_to_card("🂡").suite)
