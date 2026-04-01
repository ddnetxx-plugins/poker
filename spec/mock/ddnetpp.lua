local ddnetpp = {
	server = {},
	snap = {}
}

function ddnetpp.server.occupy_client_id(client_id)
	-- could catch duplicated occupies here
	return true
end

function ddnetpp.server.client_name(client_id)
	return "mock"
end

function ddnetpp.send_chat_target(client_id, message)
	print("[to cid=" .. client_id .. "][chat] *** " .. message)
end

function ddnetpp.secure_rand_below(max)
	return math.random(max)
end

local next_snap_id = 0

function ddnetpp.snap.new_id()
	local id = next_snap_id
	next_snap_id = next_snap_id + 1
	return id
end

function ddnetpp.snap.new_client_info(item)
end

function ddnetpp.snap.new_player_info(item)
end

function ddnetpp.snap.new_character(item)
end

function ddnetpp.snap.new_laser(item)
end

return ddnetpp
