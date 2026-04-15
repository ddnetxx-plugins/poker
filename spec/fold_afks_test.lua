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

-- afk is next to act
ddnetpp.get_player(1):set_afk(true)
t.assert_eq(1, game:next_to_act().client_id)

game:on_tick()

t.assert_eq("'mock1' was force folded due to being afk", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock1' folded", ddnetpp.get_chat_line(0, -1))

-- afk player got "skipped" and it is a different players turn
t.assert_eq(2, game:next_to_act().client_id)
