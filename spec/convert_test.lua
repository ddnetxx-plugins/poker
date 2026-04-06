-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/card_converter")

assert_eq(card_to_str({ suite = "clubs", rank = 14 }), "🃑")
assert_eq(card_to_str({ suite = "spades", rank = 2 }), "🂢")
assert_eq(card_to_str({ suite = "hearts", rank = 4 }), "🂴")
assert_eq(card_to_str({ suite = "diamonds", rank = 4 }), "🃄")
assert_eq(card_to_str({ suite = "clubs", rank = 4 }), "🃔")
assert_eq(card_to_str({ suite = "clubs", rank = 14 }), "🃑")
assert_eq(card_to_str({ suite = "clubs", rank = 2 }), "🃒")
