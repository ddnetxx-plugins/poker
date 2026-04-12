local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 }, 20)
game:join_table(10) -- utg+6
game:join_table(11) -- btn
game:join_table(12) -- sb
game:join_table(20) -- bb
game:join_table(19) -- utg
game:join_table(18) -- utg+1
game:join_table(43) -- utg+2
game:join_table(44) -- utg+3
game:join_table(45) -- utg+4
game:join_table(46) -- utg+5
game:new_game()

t.assert_eq(ButtonOffset.BUTTON, game:find_player(11).position.offset)
t.assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(12).position.offset)
t.assert_eq(ButtonOffset.BIG_BLIND, game:find_player(20).position.offset)

t.assert_eq(1, game.players[1].seat)
t.assert_eq(2, game.players[2].seat)
t.assert_eq(3, game.players[3].seat)
t.assert_eq(4, game.players[4].seat)
t.assert_eq(5, game.players[5].seat)
t.assert_eq(6, game.players[6].seat)
t.assert_eq(7, game.players[7].seat)
t.assert_eq(8, game.players[8].seat)
t.assert_eq(9, game.players[9].seat)
t.assert_eq(10, game.players[10].seat)

local players = game:sort_players_by_position()
t.assert_eq(ButtonOffset.UTG, players[1].position.offset)
t.assert_eq(ButtonOffset.UTG+1, players[2].position.offset)
t.assert_eq(ButtonOffset.UTG+2, players[3].position.offset)
t.assert_eq(ButtonOffset.UTG+3, players[4].position.offset)
t.assert_eq(ButtonOffset.UTG+4, players[5].position.offset)
t.assert_eq(ButtonOffset.UTG+5, players[6].position.offset)
t.assert_eq(ButtonOffset.UTG+6, players[7].position.offset)
t.assert_eq(ButtonOffset.BUTTON, players[8].position.offset)
t.assert_eq(ButtonOffset.SMALL_BLIND, players[9].position.offset)
t.assert_eq(ButtonOffset.BIG_BLIND, players[10].position.offset)

t.all_check(game)

t.assert_eq(GameState.FLOP, game.state)

players = game:sort_players_by_position()
t.assert_eq(ButtonOffset.SMALL_BLIND, players[1].position.offset)
t.assert_eq(ButtonOffset.BIG_BLIND, players[2].position.offset)
t.assert_eq(ButtonOffset.UTG, players[3].position.offset)
t.assert_eq(ButtonOffset.UTG+1, players[4].position.offset)
t.assert_eq(ButtonOffset.UTG+2, players[5].position.offset)
t.assert_eq(ButtonOffset.UTG+3, players[6].position.offset)
t.assert_eq(ButtonOffset.UTG+4, players[7].position.offset)
t.assert_eq(ButtonOffset.UTG+5, players[8].position.offset)
t.assert_eq(ButtonOffset.UTG+6, players[9].position.offset)
t.assert_eq(ButtonOffset.BUTTON, players[10].position.offset)
