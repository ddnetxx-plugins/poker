---@class PokerPlayer
PokerPlayer = {
	client_id = 0,
	---@type string[]
	hole_cards = {},
	---@type PlayerAction|nil
	action = nil
}

function PokerPlayer:new(o, client_id)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.client_id = client_id
	self.hole_cards = {}
	self.action = nil
	return o
end
