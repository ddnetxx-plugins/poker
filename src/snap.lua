---@param snap_id integer
---@param pos Position
---@param card string
function display_card(snap_id, pos, card)
	ddnetpp.snap.new_client_info({
		id = snap_id,
		name = card,
		skin = "x_spec",
	})
	ddnetpp.snap.new_player_info({
		id = snap_id,
		client_id = snap_id,
		is_local = false,
	})
	ddnetpp.snap.new_character({
		id = snap_id,
		pos = pos,
		weapon = ddnetpp.weapon.NONE,
	})
end

return {
	display_card = display_card
}
