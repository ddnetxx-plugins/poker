local protocol = {
	POWERUP_HEALTH = 0,
	POWERUP_ARMOR = 1,
	POWERUP_WEAPON = 2,
	POWERUP_NINJA = 3,

	WEAPON_HAMMER = 0,
	WEAPON_GUN = 1,
	WEAPON_SHOTGUN = 2,
	WEAPON_GRENADE = 3,
	WEAPON_LASER = 4,
	WEAPON_NINJA = 5,
	NUM_WEAPONS = 6,
}

---@class mock.ddnet
local ddnetpp = {
	strict_occupy = false,
	verbosity = 1,
	players = {},
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
	money_transactions = {
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
	protocol = protocol,
	ticks_passed = 0,
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

function ddnetpp.get_money_transaction_line(client_id, offset)
	local lines = ddnetpp.money_transactions.lines_cid[client_id]
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

---@param client_id ClientId
---@return integer
local function client_id_to_integer(client_id)
	if type(client_id) == "number" then
		return client_id
	end
	-- player instance
	if client_id.client_id then
		return client_id.client_id
	end
	-- character instance
	return client_id:id()
end

---@param client_id ClientId
---@param message integer
function ddnetpp.send_chat_as(client_id, message)
	local cid = client_id_to_integer(client_id)
	local name = ddnetpp.server.client_name(client_id)
	if ddnetpp.chat.silent == false then
		print("[chat] " .. name .. ": " .. message)
	end
	table.insert(ddnetpp.chat.lines, message)
end

---@param client_id ClientId
---@return boolean
function ddnetpp.is_server_tee(client_id)
	local cid = client_id_to_integer(client_id)
	local player = ddnetpp.get_player(cid)
	if not player then
		return false
	end
	return player._is_dummy
end

---@return integer|nil client_id
local function find_free_cid()
	for i = 0, 127 do
		local occupied = false
		for _, occupied_id in ipairs(occupied_ids) do
			if i == occupied_id then
				occupied = true
				break
			end
		end

		if not ddnetpp.get_player(i) and not occupied then
			return i
		end
	end
	return nil
end

---@param silent? boolean
---@return integer|nil client_id
function ddnetpp.create_tee(silent)
	local cid = find_free_cid()
	if cid == nil then
		return nil
	end
	local player = Player:new(cid)
	player._is_dummy = true
	ddnetpp.players[cid] = player
	return cid
end

---@param client_id integer
---@param silent? boolean
function ddnetpp.drop_tee(client_id, silent)
	local player = ddnetpp.get_player(client_id)
	assert(player._is_dummy == true, "tried to use drop tee on a human")
	if silent == false then
		ddnetpp.send_chat(
			"'" .. ddnetpp.server.client_name(client_id) "' left the game"
		)
	end
	ddnetpp.players[cid] = nil
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
Player.__index = Player

function Player:new(client_id)
	local o = {}
	setmetatable(o, self)
	o.__index = self
	o.client_id = client_id
	o._is_afk = false
	o._money = 5000000
	o._is_dummy = false
	return o
end

-- fill server pretty full with fake players
-- so we can let them sit on the table
-- but also have some free client ids
for i = 0, 47 do
	ddnetpp.players[i] = Player:new(i)
end

function Player:name()
	return "mock" .. self.client_id
end

function Player:money()
	return self._money
end

---@param afk boolean
function Player:set_afk(afk)
	self._is_afk = afk
end

---@return boolean afk
function Player:is_afk()
	return self._is_afk
end

---@param money integer
---@param description string
function Player:money_transaction(money, description)
	self._money = self._money + money

	local client_id = self.client_id
	local amount = ""
	if money > 0 then
		amount = "+" .. money
	else
		amount = tostring(money)
	end
	local msg = amount .. " (" .. description .. ")"
	if ddnetpp.money_transactions.silent == false then
		print("[to cid=" .. client_id .. "][money_transaction] " .. msg)
	end
	if ddnetpp.money_transactions.lines_cid[client_id] == nil then
		ddnetpp.money_transactions.lines_cid[client_id] = {}
	end
	table.insert(ddnetpp.money_transactions.lines_cid[client_id], msg)
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

---@return Player|nil
function ddnetpp.get_player(client_id)
	return ddnetpp.players[client_id]
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

function ddnetpp.snap.new_pickup(item)
end


return ddnetpp
