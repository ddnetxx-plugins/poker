function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or "./"
end

local poker = require(script_path() .. "poker")

---@type Poker[]
local games = {}

function ddnetpp.on_init()
   local game = Poker:new(
      nil,
      {
         x = 33,
         y = 33,
      }
   )

   game:join_table(0)
   game:join_table(1)

   game:new_game()

   -- TODO: don't flop before the round of betting xd
   game:flop()

   table.insert(games, game)
end

function ddnetpp.on_snap(snapping_client)
   for _, game in pairs(games) do
      game:on_snap(snapping_client)
   end
end
