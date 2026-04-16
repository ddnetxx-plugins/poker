---@class PokerPlayer
PokerPlayer = {
	client_id = 0,
	---@type string[]
	hole_cards = {},
	-- TODO: merge this into the hold_cards array
	--       so we can also show only individual cards only
	--       and players can do "/show ace" or "/show six"
	--       or "/show spade"
	show_cards = false,
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
	-- seat number at the table
	seat = nil,
	---@type PokerHand|nil # The best hand this player has
	hand = nil,
	-- if someone called /time on this player
	-- this value will be above 0 which means a timer is running
	-- if it hits zero the player will be folded
	-- and zero also means no timer is running
	clock_ticks = 0,
}
PokerPlayer.__index = PokerPlayer

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
	o.seat = nil
	o.hand = nil
	return o
end
