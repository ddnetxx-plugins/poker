local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg (limp,call)
game:join_table(1) -- btn (limp,fold)
game:join_table(2) -- sb (raise)
game:join_table(3) -- bb (call)

-- the small blind happens to be omegarich
-- and he will raise big a lot :D
-- making calling quite expensive
-- for the brokies
game:find_player(2).chips = game.start_stack * 10

game:new_game()

game:player_action(0, { action = "call" })
game:player_action(1, { action = "call" })
game:player_action(2, { action = "raise", amount = game:find_player(0).chips * 2 })
game:player_action(3, { action = "call" })
t.assert_eq("This call made you go all in!", ddnetpp.get_chat_line(3, -1))
game:player_action(0, { action = "call" })
t.assert_eq("This call made you go all in!", ddnetpp.get_chat_line(0, -2))
game:player_action(1, { action = "fold" })

-- everybody acted but it is still pre flop
-- that is because we entered the showdown state
-- and all cards will be dramatically revealed on
-- the board after a few ticks
t.assert_eq(true, game.is_showdown)
t.assert_eq(GameState.PRE_FLOP, game.state)

for _, player in ipairs(game:players_with_cards()) do
	assert(player.show_cards == true, "expected cid=" .. player.client_id .. " to show their cards")
end
-- client id 1 folded
t.assert_eq(false, game:find_player(1).show_cards)
