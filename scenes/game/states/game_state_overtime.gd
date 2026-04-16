class_name GameStateOvertime
extends GameState

func _enter_tree() -> void:
	GameEvents.team_scored.connect(on_team_scored.bind())

func _process(delta: float) -> void:
	manager.time_left -= delta

func on_team_scored(team: Team) -> void:
	var _data := GameStateData.build().set_scored_side(team.side)
	state_transition(GameManager.State.SCORED, _data)
