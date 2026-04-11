local assert_eq = require("simple.assert").assert_eq
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 }, 5)
game:join_table(0) -- co
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:join_table(4) -- utg
game:new_game()

game:leave_table(4)
game:leave_table(3)
game:leave_table(2)
game:leave_table(1)

assert_eq("You won the entire pot with 150 chips in it!", ddnetpp.get_chat_line(0, -3))
assert_eq("'mock0' won because everyone folded", ddnetpp.get_chat_line(0, -2))
assert_eq("'mock0' won the entire game! And collected 10 in prize money!", ddnetpp.get_chat_line(0, -1))
assert_eq(GameState.END, game.state)
