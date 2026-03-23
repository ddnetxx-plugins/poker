function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or "./"
end

local poker = require(script_path() .. "poker")

---@type Poker[]
local games = {}

function ddnetpp.on_init()
   table.insert(games, Poker:new(nil, { x = 0, y = 0 }))
end

function ddnetpp.on_snap()
   for _, game in pairs(games) do
      game:on_snap()
   end
end
