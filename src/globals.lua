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

