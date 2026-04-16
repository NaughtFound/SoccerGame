class_name GameStateReset
extends GameState

var is_team_ready: Dictionary[Team.TeamSide, bool]

func _enter_tree() -> void:
	assert(data != null)
	
	GameEvents.team_kickoff_ready.connect(on_team_kickoff_ready.bind())
	GameEvents.team_reset.emit()
	is_team_ready = {
		Team.TeamSide.Home: false,
		Team.TeamSide.Away: false,
	}

func _process(_delta: float) -> void:
	for is_ready in is_team_ready.values():
		if not is_ready:
			return
	state_transition(GameManager.State.KICKOFF, data)

func on_team_kickoff_ready(_team: Team) -> void:
	is_team_ready[_team.side] = true
