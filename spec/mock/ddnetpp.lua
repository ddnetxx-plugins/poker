local ddnetpp = {
	server = {},
	snap = {},
	weapon = {
		NONE = -1
	}
}

function ddnetpp.server.occupy_client_id(client_id)
	-- could catch duplicated occupies here
	return true
end

function ddnetpp.server.client_name(client_id)
	return "mock" .. client_id
end

function ddnetpp.send_chat_target(client_id, message)
	print("[to cid=" .. client_id .. "][chat] *** " .. message)
end

Player = {}

function Player:new(client_id)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	self.client_id = client_id
	return o
end

function Player:name()
	return "mock" .. self.client_id
end

Character = {}

function Character:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Character:pos()
	return { x = 0, y = 0 }
end

function ddnetpp.get_character(client_id)
	return Character:new()
end

function ddnetpp.get_player(client_id)
	return Player:new(client_id)
end

function ddnetpp.secure_rand_below(max)
	return math.random(max)
end
function ddnetpp.laser_text(pos, text, ticks)
	print("[laser_text] " .. text)
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
