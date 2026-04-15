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
game:find_player(1).chips = 10

-- rich player with 100 chips raises to 10
-- putting the other player all in
game:player_action(0, { action = "raise", amount = 10 })

-- that other player tries to raise to 5 while having 10
-- chips, sounds good at first but he is facing a bet
-- so raising to 5 while facing a bet of 10
-- is 15 which is more than the balance of this player
game:player_action(1, { action = "raise", amount = 5 })
t.assert_eq("You do not have that many chips!", ddnetpp.get_chat_line(1, -1))

game:player_action(1, { action = "raise", amount = 0 })
t.assert_eq("bruder was", ddnetpp.get_chat_line(1, -1))

game:player_action(1, { action = "check"  })
t.assert_eq("You can not check. You need to pay at least 10 chips to call.", ddnetpp.get_chat_line(1, -1))

game:player_action(1, { action = "call"  })
t.assert_eq("'mock1' called", ddnetpp.get_chat_line(1, -1))

-- the call put the player all in
t.assert_eq(0, game:find_player(1).chips)
