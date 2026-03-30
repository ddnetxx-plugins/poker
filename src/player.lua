---@class PokerPlayer
PokerPlayer = {
	client_id = 0,
	---@type string[]
	hole_cards = {},
	---@type PlayerAction|nil
	action = nil,
}

function PokerPlayer:new(client_id)
	local o = {}
	setmetatable(o, self)
	o.__index = self
	o.client_id = client_id
	o.hole_cards = {}
	o.action = nil
	return o
end
