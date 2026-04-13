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

print(ddnetpp.get_chat_line(0, -3))
print(ddnetpp.get_chat_line(0, -2))
print(ddnetpp.get_chat_line(0, -1))
-- t.assert_eq("", ddnetpp.get_chat_line(0, -1))
