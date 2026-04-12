local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb

game:find_player(2).chips = game.start_stack * 2
game:find_player(3).chips = game.start_stack * 4

game:new_game()

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(1, { action = "fold" })

t.assert_eq("It is not your turn yet, please wait", ddnetpp.get_chat_line(1, -1))
