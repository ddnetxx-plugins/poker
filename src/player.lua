---@class PokerPlayer
PokerPlayer = {
	client_id = 0,
	---@type string[]
	hole_cards = {},
	chips = 0,
	chips_paid_into_pot = 0,
	---@type integer[]
	hole_card_snap_ids = {},
	---@type PlayerAction|nil
	action = nil,
	--- all actions of one betting round
	--- to keep track of 3 bets and stuff like that
	---@type PlayerAction[]
	prev_actions = {},
	is_button = false,
	position = {
		name = "small blind",
		offset = ButtonOffset.SMALL_BLIND,
	},
}

function PokerPlayer:new(client_id)
	local o = {}
	setmetatable(o, self)
	o.__index = self
	o.client_id = client_id
	o.hole_cards = {}
	o.chips = 0
	o.hole_card_snap_ids = {}
	o.action = nil
	o.is_button = false
	o.position = {
		name = "small blind",
		offset = ButtonOffset.SMALL_BLIND,
	}
	return o
end
