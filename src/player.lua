---@class PokerPlayer
PokerPlayer = {
	client_id = 0
}

function PokerPlayer:new(o, client_id)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.client_id = client_id
	return o
end
