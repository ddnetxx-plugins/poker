local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb

-- the small blind happens to be omegarich
-- and he will raise big a lot :D
-- making calling quite expensive
-- for the brokies
game:find_player(2).chips = game.start_stack * 10

game:new_game()

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃑🃞

-- ace kicker wins quads
t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")

game:player_action(0, { action = "call" })
game:player_action(1, { action = "call" })
-- omg this is personal :D
game:player_action(2, { action = "raise", amount = game:find_player(0).chips * 2 })
game:player_action(3, { action = "call" })
t.assert_eq("This call made you go all in!", ddnetpp.get_chat_line(3, -1))
t.assert_eq(0, game:find_player(3).chips)
t.assert_eq(2, #game:find_player(3).hole_cards)

game:player_action(0, { action = "call" })
t.assert_eq("This call made you go all in!", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock0' did a call", ddnetpp.get_chat_line(0, -1))
t.assert_eq(0, game:find_player(0).chips)
t.assert_eq(2, #game:find_player(0).hole_cards)

t.assert_eq(GameState.PRE_FLOP, game.state)
game:player_action(1, { action = "fold" })
t.assert_eq(49900, game:find_player(1).chips)
t.assert_eq(0, #game:find_player(1).hole_cards)

-- everybody acted but it is still pre flop
-- that is because we entered the showdown state
-- and all cards will be dramatically revealed on
-- the board after a few ticks
t.assert_eq(true, game.is_showdown)
t.assert_eq(GameState.PRE_FLOP, game.state)

-- we are too lazy to call on tick so we rig the game manually
game:flop()
game:turn()
game:river()
t.rig_board(game, "🂤🂴🃄🃔🃕")
game:next_state()

-- mock0 client id 0 won with quads and ace kicker and we move on to the next pre flop
t.assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))
t.assert_eq(GameState.PRE_FLOP, game.state)

-- here is what happend we have one
-- chip bully who raised with a size that covers everyone
-- 2 players called and went all in
-- one of them won the pot
-- so the chip bully, the folder and the all in winner stay alive
-- the second all in player is seat open
--
-- cid=0 ALL IN (best cards)
-- cid=1   FOLD
-- cid=2  BULLY
-- cid=3 ALL IN

t.assert_eq(2, #game:find_player(0).hole_cards)
t.assert_eq(2, #game:find_player(1).hole_cards)
t.assert_eq(2, #game:find_player(2).hole_cards)
t.assert_eq(0, #game:find_player(3).hole_cards) -- seat open
