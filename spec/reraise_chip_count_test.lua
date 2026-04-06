-- local assert_eq = require("simple.assert").assert_eq
local assert_eq = require("spec.simple_assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- button
game:join_table(2) -- small blind
game:join_table(3) -- big blind
game:new_game()

game:find_player(0).chips = 100
game:find_player(1).chips = 15

assert_eq(4, game:num_players_in_hand())
assert_eq(0, game:next_to_act().client_id)

-- rich player with 100 chips raises to 10
game:player_action(0, { action = "raise", amount = 10 })

-- that other player tries to raise to 6 while having 15
-- chips, sounds good at first but he is facing a bet
-- so raising to 6 while facing a bet of 10
-- is 16 which is more than the balance of this player
game:player_action(1, { action = "raise", amount = 6 })
assert_eq("You do not have that many chips!", ddnetpp.get_chat_line(1, -1))

game:player_action(1, { action = "raise", amount = 2 })
assert_eq("'mock1' did a raise", ddnetpp.get_chat_line(1, -1))

-- fold the blinds
game:player_action(2, { action = "fold" })
game:player_action(3, { action = "fold" })

-- now utg is facing the reraise of the btn
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })

-- two players at the flop: utg and btn
assert_eq(GameState.FLOP, game.state)
assert_eq(2, game:num_players_in_hand())

-- utg should be first to act
assert_eq(0, game:next_to_act().client_id)  -- FIXME: this test fails! we get "2" (sb) instead of utg but sb already folded
