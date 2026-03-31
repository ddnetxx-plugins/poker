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
         y = 3,
      }
   )

   game:join_table(0)
   game:join_table(1)

   game:new_game()

   -- game:player_action(1, { action = "check" })
   -- game:player_action(0, { action = "check" })

   table.insert(games, game)
end

function ddnetpp.on_snap(snapping_client)
   for _, game in pairs(games) do
      game:on_snap(snapping_client)
   end
end

function ddnetpp.on_tick()
   for _, game in pairs(games) do
      game:on_tick()
   end
end

ddnetpp.register_chat("snap", "", "", function (client_id, args)
   ddnetpp.send_chat("new snap id: " .. ddnetpp.snap.new_id())
end)

ddnetpp.register_chat("check", "", "check to next player in poker", function (client_id, args)
   for _, game in pairs(games) do
      if game:is_at_table(client_id) then
         game:player_action(client_id, { action = "check" })

          -- no multi table support yet -.-
         return
      end
   end
   ddnetpp.log_info("chatresp", "You are not any poker table")
end)
