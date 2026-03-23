---@param snap_id integer
---@param pos Position
---@param card string
function display_card(snap_id, pos, card)
	ddnetpp.snap.new_client_info({
		id = snap_id,
		name = card,
		clan = "",
		skin = "x_spec",
		use_custom_color = false,
	})
	ddnetpp.snap.new_player_info({
		id = snap_id,
		client_id = snap_id,
		is_local = false,
		team = ddnetpp.team.GAME,
		score = 0,
		latency = 0,
	})
	ddnetpp.snap.new_character({
		id = snap_id,
		tick = 10,
		pos = pos,
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

return {
	display_card = display_card
}
