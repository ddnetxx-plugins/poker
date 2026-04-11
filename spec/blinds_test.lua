local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb
game:new_game()

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃑🃞

-- small plus big blind is the same as 3 small blinds
t.assert_eq(game.small_blind * 3, game.pot)

t.assert_eq(game.start_stack, game:find_player(0).chips)
t.assert_eq(game.start_stack, game:find_player(1).chips)
t.assert_eq(game.start_stack - game.small_blind * 1, game:find_player(2).chips) -- sb
t.assert_eq(game.start_stack - game.small_blind * 2, game:find_player(3).chips) -- bb

t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")
t.all_check_call_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")
t.assert_eq("You won the entire pot with 400 chips in it!", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))

local limps = game.small_blind * 2 * game:num_players_with_chips()
-- remove the winners limp from the prize
limps = limps - game.small_blind * 2
-- the winner moved from utg to bb and we are already pre flop
-- so the winner had to place one big blind already
limps = limps - game.small_blind * 2
t.assert_eq(game.start_stack + limps, game:find_player(0).chips)

-- two ace kicker quads split pot
t.set_hole_cards(game, 0, "🂡🂮") -- ace kicker for quads
t.set_hole_cards(game, 1, "🂱🃁") -- same ace kicker for quads
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")
t.all_check_call_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")
t.assert_eq("You won a split pot with 200 chips in it!", ddnetpp.get_chat_line(1, -2))
t.assert_eq("You won a split pot with 200 chips in it!", ddnetpp.get_chat_line(0, -3))
