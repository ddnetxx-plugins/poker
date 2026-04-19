---@alias BotName string
---|"'calling_machine'"
---|"'folding_machine'"
---|"'goof'"

---@class PokerBot
---
---@field name BotName
---@field new fun(game: Poker)
---@field on_turn fun() # This is not the "turn" game state its the turn to act for the but
