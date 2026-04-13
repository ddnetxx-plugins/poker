---@alias Suit string
---|"'spades'"
---|"'hearts'"
---|"'diamonds'"
---|"'clubs'"

---@type Suit[]
SUITS = {
	"spades",
	"hearts",
	"diamonds",
	"clubs"
}

CARDS = {
	"🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩", "🂪", "🂫", "🂭", "🂮", "🂡", -- Spades
	"🂲", "🂳", "🂴", "🂵", "🂶", "🂷", "🂸", "🂹", "🂺", "🂻", "🂽", "🂾", "🂱", -- Hearts
	"🃂", "🃃", "🃄", "🃅", "🃆", "🃇", "🃈", "🃉", "🃊", "🃋", "🃍", "🃎", "🃁", -- Diamonds
	"🃒", "🃓", "🃔", "🃕", "🃖", "🃗", "🃘", "🃙", "🃚", "🃛", "🃝", "🃞", "🃑", -- Clubs
}

ButtonOffset = {
	BUTTON = 0,
	SMALL_BLIND = 1,
	BIG_BLIND = 2,
	UTG = 3,
}
GameState = {
	END = -2,
	ERROR = -1,
	WAITING_FOR_PLAYERS = 0,
	PRE_FLOP = 1,
	FLOP = 2,
	TURN = 3,
	RIVER = 4,
}

function gamestate_to_str(state)
	if state == GameState.END then
		return "END"
	elseif state == GameState.ERROR then
		return "ERROR"
	elseif state == GameState.WAITING_FOR_PLAYERS then
		return "WAITING_FOR_PLAYERS"
	elseif state == GameState.PRE_FLOP then
		return "PRE_FLOP"
	elseif state == GameState.FLOP then
		return "FLOP"
	elseif state == GameState.TURN then
		return "TURN"
	elseif state == GameState.RIVER then
		return "RIVER"
	end
	return "(unknown)"
end

