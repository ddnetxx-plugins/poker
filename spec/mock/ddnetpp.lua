---@class mock.ddnet
local ddnetpp = {
	strict_occupy = false,
	verbosity = 1,
	chat = {
		silent = false,
		---@type string[]
		lines = {},
		-- key is the client id
		-- and value is an array of direct messages
		lines_cid = {},
	},
	broadcast = {
		silent = true,
		---@type string[]
		lines = {},
		-- key is the client id
		-- and value is an array of direct messages
		lines_cid = {},
	},
	server = {},
	snap = {},
	weapon = {
		NONE = -1
	},
	ticks_passed = 0
}

function ddnetpp.get_chat_line(client_id, offset)
	local lines = ddnetpp.chat.lines_cid[client_id]
	if lines == nil then
		return nil
	end
	if offset >= 0 then
		return lines[offset]
	end
	return lines[#lines+offset+1]
end

function ddnetpp.get_broadcast_line(client_id, offset)
	local lines = ddnetpp.broadcast.lines_cid[client_id]
	if lines == nil then
		return nil
	end
	if offset >= 0 then
		return lines[offset]
	end
	return lines[#lines+offset+1]
end

local occupied_ids = {}

function ddnetpp.server.tick_speed()
	return 50
end

---@param client_id integer
---@return boolean
function ddnetpp.server.occupy_client_id(client_id)
	for _, cid in ipairs(occupied_ids) do
		if cid == client_id then
			assert(ddnetpp.strict_occupy == false, "client id " .. client_id .. " was already occupied!")
			return false
		end
	end
	table.insert(occupied_ids, client_id)
	return true
end

---@param client_id integer
---@return boolean
function ddnetpp.server.free_occupied_client_id(client_id)
	for i, cid in ipairs(occupied_ids) do
		if cid == client_id then
			table.remove(occupied_ids, i)
			return true
		end
	end
	if ddnetpp.strict_occupy then
		assert(false, "client id " .. client_id .. " was not occupied!")
	end
	return false
end

function ddnetpp.server.client_name(client_id)
	return "mock" .. client_id
end

function ddnetpp.server.tick()
	return ddnetpp.ticks_passed
end

---@param client_id ClientId
---@param score_type ScoreType
function ddnetpp.set_client_score_type(client_id, score_type) end

function ddnetpp.send_chat(message)
	if ddnetpp.chat.silent == false then
		print("[chat] *** " .. message)
	end
	table.insert(ddnetpp.chat.lines, message)
end

function ddnetpp.plugin_name()
	return "mock_plugin"
end

function ddnetpp.log_info(sys, message)
	if message == nil then
		message = sys
		sys = ddnetpp.plugin_name()
	end
	if ddnetpp.verbosity > 0 then
		print("I " .. sys .. ": " .. message)
	end
end

function ddnetpp.log_warn(sys, message)
	if message == nil then
		message = sys
		sys = ddnetpp.plugin_name()
	end
	if ddnetpp.verbosity > 0 then
		print("W " .. sys .. ": " .. message)
	end
end

function ddnetpp.log_error(sys, message)
	if message == nil then
		message = sys
		sys = ddnetpp.plugin_name()
	end
	print("E " .. sys .. ": " .. message)
end

function ddnetpp.send_chat_target(client_id, message)
	if ddnetpp.chat.silent == false then
		print("[to cid=" .. client_id .. "][chat] *** " .. message)
	end
	if ddnetpp.chat.lines_cid[client_id] == nil then
		ddnetpp.chat.lines_cid[client_id] = {}
	end
	table.insert(ddnetpp.chat.lines_cid[client_id], message)
end

function ddnetpp.send_broadcast_target(client_id, message)
	if ddnetpp.broadcast.silent == false then
		print("[to cid=" .. client_id .. "][broadcast] " .. message)
	end
	if ddnetpp.broadcast.lines_cid[client_id] == nil then
		ddnetpp.broadcast.lines_cid[client_id] = {}
	end
	table.insert(ddnetpp.broadcast.lines_cid[client_id], message)
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
	if ddnetpp.verbosity > 0 then
		print("[laser_text] " .. text)
	end
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
