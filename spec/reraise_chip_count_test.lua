local assert_eq = require("simple.assert").assert_eq
local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- button
game:join_table(2) -- small blind
game:join_table(3) -- big blind

-- hack because i am too lazy to refactor the test xd
game.small_blind = 0

game:new_game()

game:find_player(0).chips = 100
game:find_player(1).chips = 15

assert_eq(4, game:num_players_with_cards())
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
assert_eq("'mock1' raised by 2 chips", ddnetpp.get_chat_line(1, -1))
assert_eq(3, game:find_player(1).chips)

-- fold the blinds
game:player_action(2, { action = "fold" })
game:player_action(3, { action = "fold" })

-- now utg is facing the reraise of the btn
assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })
assert_eq(24, game.pot)

-- two players at the flop: utg and btn
assert_eq(GameState.FLOP, game.state)
assert_eq(2, game:num_players_with_cards())

-- utg should be first to act
assert_eq(0, game:next_to_act().client_id)

game:player_action(0, { action = "check" })
game:player_action(1, { action = "raise", amount = 1 })
game:player_action(0, { action = "fold" })

-- a win by fold should not cause a showdown
t.assert_eq(false, game.is_showdown)
t.assert_eq(27, game:find_player(1).chips)
