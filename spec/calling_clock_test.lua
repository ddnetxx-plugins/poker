local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:new_game()

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })

t.assert_eq(1, game:next_to_act().client_id)

-- literally no time passed but cid 0 is already impatient and calls the clock xd
game:player_action(0, { action = "time" })
t.assert_eq("It is 'mock1's turn since 0.0 seconds. You can not call the clock yet", ddnetpp.get_chat_line(0, -1))

-- one minute later
t.fake_server_ticks(game, ddnetpp.server.tick_speed() * 60)

game:player_action(0, { action = "time" })
t.assert_eq("'mock0' called the clock! Now 'mock1' has 60 seconds to act.", ddnetpp.get_chat_line(0, -1))

-- it is still mock1's turn
t.assert_eq(1, game:next_to_act().client_id)

-- let 30 seconds pass
for _ = 1, ddnetpp.server.tick_speed() * 30 do
	game:on_tick()
end

-- it is still mock1's turn
t.assert_eq(1, game:next_to_act().client_id)

-- let another 30 seconds pass
for _ = 1, ddnetpp.server.tick_speed() * 30 do
	game:on_tick()
end

t.assert_eq("'mock1' was force folded by clock", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock1' folded", ddnetpp.get_chat_line(0, -1))

-- it is the next players turn
t.assert_eq(2, game:next_to_act().client_id)
