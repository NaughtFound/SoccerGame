class_name GameStateKickOff
extends GameState

const PRE_KICKOFF_DURATION := 1000

var time_since_pre_kickoff: int

func _enter_tree() -> void:
	assert(data != null)
	time_since_pre_kickoff = Time.get_ticks_msec()
	
func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_pre_kickoff > PRE_KICKOFF_DURATION:
		GameEvents.kickoff_started.emit()
		state_transition(GameManager.State.IN_PLAY)
		SoundPlayer.play(SoundPlayer.Sound.WHISTLE)
