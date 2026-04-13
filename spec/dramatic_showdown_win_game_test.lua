local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb

game:find_player(0).chips = game.start_stack * 10

game:new_game()

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃑🃞

t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "raise", amount = game.start_stack * 2 })
game:player_action(1, { action = "call" })
game:player_action(2, { action = "call" })
game:player_action(3, { action = "call" })

t.assert_eq(true, game.is_showdown)
t.assert_eq(GameState.PRE_FLOP, game.state)

t.next_showdown_card(game) -- flop
t.next_showdown_card(game) -- turn
t.next_showdown_card(game) -- river

t.rig_board(game, "🂤🂴🃄🃔🃕")

t.next_showdown_card(game) -- pick winner -> pre flop next round

-- cid 0 with the biggest stack won the entire game by raising big
-- everyone went all in by calling and cid 0 won the quads board
-- with the best kicker (ace)
-- the game is now in state end
-- and cid 0 won the prize money
t.assert_eq("You won the entire pot with 250100 chips in it!", ddnetpp.get_chat_line(0, -3))
t.assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock0' won the entire game! And collected 40 in prize money!", ddnetpp.get_chat_line(0, -1))
t.assert_eq(GameState.END, game.state)

-- game is over nobody still sitting at the table can do anything
game:player_action(1, { action = "raise" })
t.assert_eq("The game is not running yet", ddnetpp.get_chat_line(1, -1))

game:player_action(0, { action = "check" })
t.assert_eq("The game is not running yet", ddnetpp.get_chat_line(1, -1))

game:leave_table(1)
game:leave_table(0)
game:leave_table(3)
game:leave_table(2)

-- this is a bit weird but ok
-- still not sure how to properly cleanup ended games
-- should they self destruct and free the client ids?
-- or is that the responsibility
-- of the main.lua which manages the game instances
game:join_table(1)
t.assert_eq("Only 0 players remaining, wait until the next game", ddnetpp.get_chat_line(1, -1))
