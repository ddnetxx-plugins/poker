function snap_card(client_id, pos_x, card)
	ddnetpp.snap.new_client_info({
		id = client_id,
		name = card,
		clan = "",
		skin = "x_spec",
		use_custom_color = false,
	})
	ddnetpp.snap.new_player_info({
		id = client_id,
		client_id = client_id,
		is_local = false,
		team = ddnetpp.team.GAME,
		score = 0,
		latency = 0,
	})
	ddnetpp.snap.new_character({
		id = client_id,
		tick = 10,
		pos = {
			x = 10 + pos_x,
			y = 30,
		},
		vel_x = 10,
		vel_y = 10,
		angle = 0,
		direction = 1,
		jumped = 1,
		hooked_player = 0,
		hook_state = ddnetpp.hook.GRABBED,
		hook_tick = 2,
		hook_x = 2,
		hook_y = 2,
		hook_dx = 2,
		hook_dy = 2,
		player_flags = 2,
		health = 2,
		armor = 2,
		ammo_count = -1,
		weapon = ddnetpp.weapon.NONE,
		-- eye_emote = ddnetpp.eye_emote.PAIN,
		-- attack_tick = 3,
	})
end

function ddnetpp.on_snap()
	local cards = {
		{ "🂡", "🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂬", "🂭", "🂮" }, -- Spades
		{ "🂱", "🂲", "🂳", "🂴", "🂵", "🂶", "🂷", "🂸", "🂹", "🂺", "🂻", "🂼", "🂽", "🂾" }, -- Hearts
		{ "🃁", "🃂", "🃃", "🃄", "🃅", "🃆", "🃇", "🃈", "🃉", "🃊", "🃋", "🃌", "🃍", "🃎" }, -- Diamonds
		{ "🃑", "🃒", "🃓", "🃔", "🃕", "🃖", "🃗", "🃘", "🃙", "🃚", "🃛", "🃜", "🃝", "🃞" }, -- Clubs
	}

	for i = 10, 15, 1 do
		local idx = i
		if idx > 14 then
			idx = 14
		end
		local card = cards[1][idx]
		snap_card(i, i * 2, card)
	end
end
