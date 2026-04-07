-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/globals")
require("../src/card_converter")

assert_eq("🃑", card_to_str({ suit = "clubs", rank = 14 }))
assert_eq("🂢", card_to_str({ suit = "spades", rank = 2 }))
assert_eq("🂴", card_to_str({ suit = "hearts", rank = 4 }))
assert_eq("🃄", card_to_str({ suit = "diamonds", rank = 4 }))
assert_eq("🃔", card_to_str({ suit = "clubs", rank = 4 }))
assert_eq("🃑", card_to_str({ suit = "clubs", rank = 14 }))
assert_eq("🃒", card_to_str({ suit = "clubs", rank = 2 }))

assert_eq(2, str_to_card("🃒").rank)
assert_eq("clubs", str_to_card("🃒").suit)

assert_eq(4, str_to_card("🃔").rank)
assert_eq("clubs", str_to_card("🃔").suit)

assert_eq(14, str_to_card("🃑").rank)
assert_eq("clubs", str_to_card("🃑").suit)

assert_eq(2, str_to_card("🃂").rank)
assert_eq("diamonds", str_to_card("🃂").suit)

assert_eq(4, str_to_card("🃄").rank)
assert_eq("diamonds", str_to_card("🃄").suit)

assert_eq(14, str_to_card("🃁").rank)
assert_eq("diamonds", str_to_card("🃁").suit)

assert_eq(14, str_to_card("🂱").rank)
assert_eq("hearts", str_to_card("🂱").suit)

assert_eq(2, str_to_card("🂲").rank)
assert_eq("hearts", str_to_card("🂲").suit)

assert_eq(2, str_to_card("🂢").rank)
assert_eq("spades", str_to_card("🂢").suit)

assert_eq(6, str_to_card("🂦").rank)
assert_eq("spades", str_to_card("🂦").suit)

assert_eq(14, str_to_card("🂡").rank)
assert_eq("spades", str_to_card("🂡").suit)
