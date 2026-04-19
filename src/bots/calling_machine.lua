CallingMachine = {
}
CallingMachine.__index = CallingMachine

---@param client_id integer
---@param game Poker
---@return table
function CallingMachine:new(client_id, game)
	local o = {}
	setmetatable(o, self)
	o.client_id = client_id
	o.game = game
	o.__index = self
	return o
end

function CallingMachine:on_turn()
	ddnetpp.send_chat_as(self.client_id, "I can't play this trash hand!")
	self.game:player_action(self.client_id, { action = "fold" })
end
