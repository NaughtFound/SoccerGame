class_name GameStateInPlay
extends GameState

func _enter_tree() -> void:
	GameEvents.team_scored.connect(on_team_scored.bind())

func _process(delta: float) -> void:
	manager.time_left -= delta

	if manager.time_left <= 0:
		var scores := manager.scores.values()
		if scores[0] == scores[1]:
			state_transition(GameManager.State.OVERTIME)
		else:
			state_transition(GameManager.State.GAMEOVER)

func on_team_scored(team: Team) -> void:
	var _data := GameStateData.build().set_scored_side(team.side)
	state_transition(GameManager.State.SCORED, _data)
