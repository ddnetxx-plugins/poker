local t = require("spec.util.test_base")
require("../src/poker")

-- ddnetpp.chat.silent = false

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

-- ace kicker wins quads
t.set_hole_cards(game, 0, "🂡🂮") -- best kicker for quads
t.set_hole_cards(game, 1, "🂢🂣")
t.set_hole_cards(game, 2, "🂵🃅")
t.set_hole_cards(game, 3, "🃋🃛")

-- t.all_check_call_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")


t.assert_eq(GameState.PRE_FLOP, game.state)
t.all_check(game)

t.assert_eq(GameState.FLOP, game.state)
t.all_check(game)
t.assert_eq(GameState.TURN, game.state)
t.all_check(game)
t.assert_eq(GameState.RIVER, game.state)
t.rig_board(game, "🂤🂴🃄🃔🃕")
t.all_check(game)
t.assert_eq(false, game.is_showdown)
t.assert_eq(GameState.SHOWDOWN, game.state)

-- TODO: the order is probably wrong

-- the first player that is forced to show
t.assert_eq("'mock2' showed 🂵🃅", ddnetpp.get_chat_line(1, -1))

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "show" })
t.assert_eq("'mock1' showed 🂢🂣", ddnetpp.get_chat_line(1, -1))

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "show" })
t.assert_eq("'mock0' showed 🂡🂮", ddnetpp.get_chat_line(0, -1))

t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "show" })
t.assert_eq("'mock3' showed 🃋🃛", ddnetpp.get_chat_line(3, -2))
t.assert_eq("next round!", ddnetpp.get_chat_line(3, -1))

-- all players decided if they want to show or fold
-- their cards after the final betting round on the river
-- already ended
-- we are still in showdown mode now
-- because now there is a second delay showing the cards
-- before we deal new cards
t.assert_eq(nil, game:next_to_act())
t.assert_eq(GameState.SHOWDOWN, game.state) -- this is unchanged
t.assert_eq(true, game.is_showdown) -- this is new

-- lets progress the time to finish the round
t.next_showdown_card(game) -- the naming of the method is a bit rigged here, no new card is coming

t.assert_eq(GameState.PRE_FLOP, game.state)
t.assert_eq("'mock0' won with best hand four of a kind (quad fours)", ddnetpp.get_chat_line(0, -1))

---------

-- just checking if we crash or not, not a proper test
t.all_check_call_till_showdown_and_rig_board(game, "🂤🂴🃄🃔🃕")

