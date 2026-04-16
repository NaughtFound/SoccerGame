class_name GameStateFactory

var states: Dictionary

func _init() -> void:
	states = {
		GameManager.State.IN_PLAY: GameStateInPlay,
		GameManager.State.SCORED: GameStateScored,
		GameManager.State.RESET: GameStateReset,
		GameManager.State.KICKOFF: GameStateKickOff,
		GameManager.State.OVERTIME: GameStateOvertime,
		GameManager.State.GAMEOVER: GameStateGameOver,
	}

func get_fresh_state(state: GameManager.State) -> GameState:
	assert(states.has(state), "State doesn't exists!")
	return states[state].new()
