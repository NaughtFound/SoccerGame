class_name GameStateScored
extends  GameState

const CELEBRATION_DURATION := 3000

var time_since_celebration: int

func _enter_tree() -> void:
	assert(data != null)
	time_since_celebration = Time.get_ticks_msec()
	GameManager.scores[data.scored_side]+= 1
	GameEvents.score_updated.emit()

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_celebration > CELEBRATION_DURATION:
		state_transition(GameManager.State.RESET, data)
