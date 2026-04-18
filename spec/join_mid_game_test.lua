local assert_eq = require("simple.assert").assert_eq
local t = require("spec.util.test_base")
require("../src/poker")
ddnetpp = require("spec.mock.ddnetpp")

ddnetpp.chat.silent = true
ddnetpp.verbosity = 0

local game = Poker:new(nil, { x = 33, y = 30 }, 6)
game:join_table(0) -- co
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:join_table(4) -- utg
game:new_game()

game:leave_table(4)
game:join_table(4) -- client id 4 rejoined or someone else with the same id joined
t.assert_eq("Please wait before rejoining the table", ddnetpp.get_chat_line(4, -1))
game:join_table(7)
t.assert_eq("'mock7' joined the table", ddnetpp.get_chat_line(7, -1))
game:leave_table(3)
game:leave_table(2)
game:leave_table(1)

-- the co wins because everybody folded implicitly by leaving the table
-- the full game is not over yet because id 7 joined new and paid for chips
-- but did not get cards yet so they play another round heads up

assert_eq("You won the entire pot with 150 chips in it!", ddnetpp.get_chat_line(0, -2))
assert_eq("'mock0' won because everyone folded", ddnetpp.get_chat_line(0, -1))
assert_eq(GameState.PRE_FLOP, game.state)
assert_eq(2, game:num_players_with_chips())
