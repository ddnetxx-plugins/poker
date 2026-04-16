local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- button
game:join_table(2) -- small blind
game:join_table(3) -- big blind
game:new_game()

t.assert_eq(0, game:next_to_act().client_id)
t.assert_eq([[your stack: 50000
paid into pot: 0
you can /fold, /call or /raise (100 to call)]], game:build_player_hud(game:find_player(0)))

-- not their turn yet but it already announces the options
t.assert_eq([[your stack: 50000
paid into pot: 0
you can /fold, /call or /raise (100 to call)]], game:build_player_hud(game:find_player(1)))

game:player_action(0, { action = "raise", amount = 10 })

t.assert_eq([[your stack: 49890
paid into pot: 110
You raised by 10]], game:build_player_hud(game:find_player(0)))

-- now it is their turn but hud is still pretty much unchanged
-- only the amount to call increased because of the raise
t.assert_eq([[your stack: 50000
paid into pot: 0
you can /fold, /call or /raise (110 to call)]], game:build_player_hud(game:find_player(1)))

-- checks through to showdown
-- because that is the next state where the hud changes
t.all_check(game)
t.assert_eq(GameState.FLOP, game.state)
t.all_check(game)
t.assert_eq(GameState.TURN, game.state)
t.all_check(game)
t.assert_eq(GameState.RIVER, game.state)
t.all_check(game)
t.assert_eq(GameState.SHOWDOWN, game.state)

t.assert_eq(3, game:next_to_act().client_id)

t.assert_eq([[your stack: 49890
paid into pot: 110
you can /fold or /show your cards]], game:build_player_hud(game:find_player(3)))

game:player_action(3, { action = "fold" })

t.assert_eq([[your stack: 49890
paid into pot: 110
Your last action was a fold]], game:build_player_hud(game:find_player(3)))
