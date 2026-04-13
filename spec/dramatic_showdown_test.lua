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

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃑🃞

-- ace kicker wins quads
t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")

game:player_action(0, { action = "fold" }) -- utg fold
game:player_action(1, { action = "fold" }) -- btn fold
t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "raise", amount = game:find_player(2).chips - game.small_blind }) -- sb all in
t.assert_eq(0, game:find_player(2).chips)
t.assert_eq("This raise made you go all in!", ddnetpp.get_chat_line(2, -2))

t.assert_eq(false, game.is_showdown)

t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "call" }) -- bb call
t.assert_eq("'mock3' did a call", ddnetpp.get_chat_line(3, -1))

t.assert_eq(true, game.is_showdown)

-- we have a heads up now
-- utg and btn folded.
-- sb is all in and bb which has the bigger stack just calls
-- we are still preflop but now the showdown will slowly reveal all cards

t.assert_eq(GameState.PRE_FLOP, game.state)
t.assert_eq(0, #game.community_cards)

-- there is no way to continue betting in showdown mode
-- all cards are open on the table and all bets were made
t.assert_eq(nil, game:next_to_act())
game:player_action(3, { action = "raise", amount = 10 })
t.assert_eq("Please wait until the showdown is over", ddnetpp.get_chat_line(3, -1))

for _ = 1, math.ceil(game.showdown_speed * ddnetpp.server.tick_speed()) do
	game:on_tick()
end
t.assert_eq(GameState.FLOP, game.state)
t.assert_eq(3, #game.community_cards)

-- make sure the flop does not reset player actions
-- and ask someone to start acting now
-- we are still in showdown until the round is over
t.assert_eq(nil, game:next_to_act())
t.assert_eq(true, game.is_showdown)

for _ = 1, math.ceil(game.showdown_speed * ddnetpp.server.tick_speed()) do
	game:on_tick()
end
t.assert_eq(GameState.TURN, game.state)
t.assert_eq(4, #game.community_cards)
t.assert_eq(nil, game:next_to_act())
t.assert_eq(true, game.is_showdown)

-- troller
game:player_action(3, { action = "check" })
t.assert_eq("Please wait until the showdown is over", ddnetpp.get_chat_line(3, -1))

for _ = 1, math.ceil(game.showdown_speed * ddnetpp.server.tick_speed()) do
	game:on_tick()
end
t.assert_eq(GameState.RIVER, game.state)
t.assert_eq(5, #game.community_cards)
t.assert_eq(nil, game:next_to_act())
t.assert_eq(true, game.is_showdown)

for _ = 1, math.ceil(game.showdown_speed * ddnetpp.server.tick_speed()) do
	game:on_tick()
end
t.assert_eq(GameState.PRE_FLOP, game.state)
t.assert_eq(false, game.is_showdown)
t.assert_ne(nil, game:next_to_act())

-- someone won now, we don't know who because we did not rig the cards
t.assert_eq(true, string.match(ddnetpp.get_chat_line(3, -1), " won ") ~= nil)

