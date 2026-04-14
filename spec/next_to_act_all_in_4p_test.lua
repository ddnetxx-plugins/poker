local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 })
game:join_table(0) -- utg
game:join_table(1) -- btn
game:join_table(2) -- sb
game:join_table(3) -- bb

-- rig big blinds chip count to be lower
-- so his all in does not force everyone else all in
game:find_player(3).chips = math.floor(game.start_stack / 2)

game:new_game()

t.assert_eq(ButtonOffset.UTG, game:find_player(0).position.offset)
t.assert_eq(ButtonOffset.BUTTON, game:find_player(1).position.offset)
t.assert_eq(ButtonOffset.SMALL_BLIND, game:find_player(2).position.offset)
t.assert_eq(ButtonOffset.BIG_BLIND, game:find_player(3).position.offset)

t.assert_eq(game.next_to_act_offset, ButtonOffset.UTG)

-- pre flop
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "call" })

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "call" })

t.assert_eq(3, game:next_to_act().client_id)
game:player_action(3, { action = "bet", amount = game:find_player(3).chips })

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "call" })

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "call" })

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "call" })

-- flop
t.assert_eq(GameState.FLOP, game.state)
t.assert_eq(ButtonOffset.BIG_BLIND, game:find_player(3).position.offset)

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

-- here we skip client id 3 (big blind) because he is already all in
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- turn
t.assert_eq(GameState.TURN, game.state)

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

-- here we skip client id 3 (big blind) because he is already all in
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })

-- river
t.assert_eq(GameState.RIVER, game.state)

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "check" })

-- here we skip client id 3 (big blind) because he is already all in
t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })

t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "check" })
t.all_show(game)
t.next_showdown_card(game)

-- pre flop (button moved)
-- before:
-- cid=0 utg
-- cid=1 btn
-- cid=2 sb
-- cid=3 bb
--
-- after:
-- cid=0 bb
-- cid=1 utg
-- cid=2 btn
-- cid=3 sb (might be be seat open, depending on the cards)

t.assert_eq(true, game:find_player(2).is_button)
local seat_open = string.match(ddnetpp.get_chat_line(0, -1), "'mock3' won") == nil

-- utg first to act
t.assert_eq(1, game:next_to_act().client_id)
game:player_action(1, { action = "call" })

t.assert_eq(2, game:next_to_act().client_id)
game:player_action(2, { action = "call" })

-- this branch is random and depends on the cards being dealt
-- client id 3 went all in previously as the shortest stack
if not seat_open then
	t.assert_eq(3, game:next_to_act().client_id)
	game:player_action(3, { action = "call" })
end

t.assert_eq(0, game:next_to_act().client_id)
game:player_action(0, { action = "check" })
