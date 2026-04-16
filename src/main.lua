local function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)") or "./"
end

require(script_path() .. "poker")

local main_game = Poker:new(
	nil,
	{
		x = 33,
		y = 30,
	}
)

function ddnetpp.on_init()
	-- TODO: allocate snap ids here but do not start round yet
end

function ddnetpp.on_snap(snapping_client)
	main_game:on_snap(snapping_client)
end

function ddnetpp.on_snap_player(snapping_client, player, item)
	return main_game:on_snap_player(snapping_client, player, item)
end

function ddnetpp.on_tick()
	main_game:on_tick()
end

function ddnetpp.on_player_disconnect(client_id)
	if main_game:is_at_table(client_id) then
		main_game:leave_table(client_id)
	end
end

ddnetpp.register_rcon("poker_state", "", "show current game state as motd", function (client_id, args)
	ddnetpp.send_motd_target(client_id, main_game:state_to_str())
end)

ddnetpp.register_rcon("poker_start", "", "force start the game when waiting for players", function (client_id, args)
	if main_game.state == GameState.WAITING_FOR_PLAYERS then
		if main_game:num_players() < 2 then
			ddnetpp.log_error("need at least 2 players to start a game")
			return
		end
		ddnetpp.log_info("force starting game...")
		main_game:new_game()
	else
		ddnetpp.log_error("failed to force start game that is in state '" .. gamestate_to_str(main_game.state) .. "'")
	end
end)

ddnetpp.register_chat("allin", "", "bet ALL your chips in poker", function (client_id, args)
	local player = main_game:find_player(client_id)
	if player then
		local diff = main_game.pot_per_player - player.chips_paid_into_pot
		local amount = player.chips - diff
		main_game:player_action(client_id, { action = "raise", amount = amount })

		-- no multi table support yet -.-
		return
	end
	ddnetpp.send_chat_target(client_id, "You are not at any poker table")
end)

-- this shadows a ddnet++ command should probably be renamed
ddnetpp.register_chat("show", "", "reveal your cards in poker", function (client_id, args)
	if main_game:is_at_table(client_id) then
		main_game:player_action(client_id, { action = "show" })

		-- no multi table support yet -.-
		return
	end
	ddnetpp.send_chat_target(client_id, "You are not at any poker table")
end)

ddnetpp.register_chat("fold", "", "muck your cards in poker", function (client_id, args)
	if main_game:is_at_table(client_id) then
		main_game:player_action(client_id, { action = "fold" })

		-- no multi table support yet -.-
		return
	end
	ddnetpp.send_chat_target(client_id, "You are not at any poker table")
end)

ddnetpp.register_chat("time", "", "call the clock in poker", function (client_id, args)
	if main_game:is_at_table(client_id) then
		main_game:player_action(client_id, { action = "time" })

		-- no multi table support yet -.-
		return
	end
	ddnetpp.send_chat_target(client_id, "You are not at any poker table")
end)

ddnetpp.register_chat("check", "", "check to next player in poker", function (client_id, args)
	if main_game:is_at_table(client_id) then
		main_game:player_action(client_id, { action = "check" })

		-- no multi table support yet -.-
		return
	end
	ddnetpp.send_chat_target(client_id, "You are not at any poker table")
end)

ddnetpp.register_chat("call", "", "call previous raise in poker", function (client_id, args)
	if main_game:is_at_table(client_id) then
		main_game:player_action(client_id, { action = "call" })

		-- no multi table support yet -.-
		return
	end
	ddnetpp.send_chat_target(client_id, "You are not at any poker table")
end)

ddnetpp.register_chat("raise", "i[amount]", "raise in poker", function (client_id, args)
	if main_game:is_at_table(client_id) then
		main_game:player_action(client_id, { action = "raise", amount = args.amount })

		-- no multi table support yet -.-
		return
	end
	ddnetpp.send_chat_target(client_id, "You are not at any poker table")
end)

ddnetpp.register_chat("poker", "?i[confirm_buy_in_amount]", "join poker table", function (client_id, args)
	if main_game:is_at_table(client_id) then
		ddnetpp.send_chat_target(client_id, "You are already at a poker table")
		return
	end

	if args.confirm_buy_in_amount ~= main_game.buy_in then
		ddnetpp.send_chat_target(client_id, "The buy in for that game is " .. main_game.buy_in .. " money!")
		ddnetpp.send_chat_target(client_id, "If you understand the risk and want to join the game use this command:")
		ddnetpp.send_chat_target(client_id, "")
		ddnetpp.send_chat_target(client_id, " /poker " .. main_game.buy_in)
		ddnetpp.send_chat_target(client_id, "")
		return
	end

	main_game:join_table(client_id)
end)
