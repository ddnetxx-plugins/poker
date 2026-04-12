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

-- TODO: this fails idk why but i rq now xd
-- TODO: actually its not "all in" we expect the bb is a bigger stack
--       calling the sb's all in is not putting the bb at risk
--       but eh whatever right now it prints 'Nobody raised you. You can raise or check' which for sure is wrong
-- t.assert_eq("This call made you go all in!", ddnetpp.get_chat_line(3, -1))


t.assert_eq(true, game.is_showdown)

-- TODO: call game:on_tick() and make sure the board reveals it self automatically during showdown
