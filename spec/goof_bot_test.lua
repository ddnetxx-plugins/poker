local t = require("spec.util.test_base")
require("../src/poker")

local game = Poker:new(nil, { x = 33, y = 30 }, 6)

-- forward compatible tests with locked properties
game.start_stack = 50000
game.num_players_needed_to_start = 4
game.small_blind = 50
game.double_blind_interval_minutes = 15
game.buy_in = 10

-- 🂢🂣🂤🂥🂦🂧🂨🂩🂪🂫🂭🂮🂡
-- 🂲🂳🂴🂵🂶🂷🂸🂹🂺🂻🂽🂾🂱
-- 🃂🃃🃄🃅🃆🃇🃈🃉🃊🃋🃍🃎🃁
-- 🃒🃓🃔🃕🃖🃗🃘🃙🃚🃛🃝🃞🃑

t.assert_eq(true, game:add_bot('goof')) -- utg
game:join_table(0) -- btn
game:join_table(1) -- sb
game:join_table(2) -- bb

-- the bots get pretty high client ids
-- because there are a bunch of fake humans connected
t.assert_eq(48, game.players[1].client_id)

-- auto start with 4 players
t.fake_server_ticks(game, 1)
t.assert_eq(GameState.PRE_FLOP, game.state)

t.set_hole_cards(game, 48, "🃞🃑")

t.assert_eq(48, game:next_to_act().client_id)
t.fake_server_ticks(game, 1)

t.assert_eq("mock48: I can't play this trash hand!", ddnetpp.get_chat_line(0, -2))
t.assert_eq("'mock48' folded", ddnetpp.get_chat_line(0, -1))
