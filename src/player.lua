---@class PokerPlayer
PokerPlayer = {
	client_id = 0,
	---@type string[]
	hole_cards = {},
	---@type integer[]
	hole_card_snap_ids = {},
	---@type PlayerAction|nil
	action = nil,
	is_button = false,
	button_offset = ButtonOffset.SMALL_BLIND,
}

function PokerPlayer:new(client_id)
	local o = {}
	setmetatable(o, self)
	o.__index = self
	o.client_id = client_id
	o.hole_cards = {}
	o.hole_card_snap_ids = {}
	o.action = nil
	o.is_button = false
	o.button_offset = ButtonOffset.SMALL_BLIND
	return o
end
