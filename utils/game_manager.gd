extends Node

const GAME_DURATION_SEC := 90

enum State {IN_PLAY, SCORED, RESET, KICKOFF, OVERTIME, GAMEOVER}

var state_factory: GameStateFactory
var current_state: GameState
var time_left: float
var countries: Dictionary[Team.TeamSide, String]
var formations: Dictionary[Team.TeamSide, TeamFormation.Style]
var control_schemes: Dictionary[Team.TeamSide, Player.ControlScheme]
var scores: Dictionary[Team.TeamSide, int]

func _init() -> void:
	state_factory = GameStateFactory.new()
	current_state = null
	countries = {
		Team.TeamSide.Home: "FRANCE",
		Team.TeamSide.Away: "GERMANY"
	}
	formations = {
		Team.TeamSide.Home: TeamFormation.Style.F_3_1_1,
		Team.TeamSide.Away: TeamFormation.Style.F_2_2_1,
	}
	control_schemes = {
		Team.TeamSide.Home: Player.ControlScheme.P1,
		Team.TeamSide.Away: Player.ControlScheme.CPU,
	}
	scores = {
		Team.TeamSide.Home: 0,
		Team.TeamSide.Away: 0
	}

func reset() -> void:
	time_left = GAME_DURATION_SEC
	scores = {
		Team.TeamSide.Home: 0,
		Team.TeamSide.Away: 0
	}
	var _data := GameStateData.build().set_scored_side(Team.TeamSide.Home)
	switch_state(State.RESET, _data)

func switch_state(state: State, data: GameStateData = null) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, data)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "GameStateMachine"
	call_deferred("add_child", current_state)

func get_winner_side() -> Team.TeamSide:
	var home_score := scores[Team.TeamSide.Home]
	var away_score := scores[Team.TeamSide.Away]
	
	if home_score == away_score:
		return Team.TeamSide.NONE
	if home_score > away_score:
		return Team.TeamSide.Home
	return Team.TeamSide.Away
