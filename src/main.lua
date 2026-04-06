local function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)") or "./"
end

require(script_path() .. "hand_ranks")
require(script_path() .. "poker")

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

function ddnetpp.on_player_disconnect(client_id)
   for _, game in pairs(games) do
      if game:is_at_table(client_id) then
         game:leave_table(client_id)
      end
   end
end

-- TODO: remove this debug command, or turn into a rcon command with a better name
ddnetpp.register_chat("state", "", "", function (client_id, args)
   ddnetpp.send_motd_target(client_id, games[1]:state_to_str())
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

-- TODO: what does the raise amount mean? Is that relative or absolute?
--       if someone raised to 10 and i want to reraise to 15
--       do i use the chat command /raise 5
--       or the chat command       /raise 15
--       ????
--       how is it in online poker usually?
--       i am currently offline omg xd
--       since i never played online poker
--       i would use the physical approach where raise takes as argument
--       how many chips you would grab with your hand
--       so doing /raise 5 would throw an error because its not even
--       enough to call
--       but then the word raise is a bit misleading
--       maybe a command like /grab_chips would be clearer then :D
--       ok maybe we can add that later
--       lets for now make a raise take the amount on top of a call as arg
--       would also be cool to be able to say "half pot" as amount :D
--       or "10bb" for 10 big blinds in general some word to chip amount
--       helper function would be really cool
ddnetpp.register_chat("raise", "i[amount]", "raise in poker", function (client_id, args)
   for _, game in pairs(games) do
      if game:is_at_table(client_id) then
         game:player_action(client_id, { action = "raise", amount = args.amount })

          -- no multi table support yet -.-
         return
      end
   end
   ddnetpp.log_info("chatresp", "You are not at any poker table")
end)
