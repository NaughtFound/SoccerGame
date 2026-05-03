class_name Team
extends Node2D

const PLAYER_PREFAB := preload("res://scenes/characters/player.tscn")
const CENTER := Vector2(425.0, 180.0)

const DURATION_WEIGHTS_CACHE := 200
var time_since_last_cache_refresh: int

enum TeamSide {Home, Away, NONE}

@export var side: TeamSide 
@export var ball: Ball
@export var own_goal: Goal
@export var target_goal: Goal

var country: String
var formation: TeamFormation.Style
var control_scheme: Player.ControlScheme
var player_positions: Dictionary[Player, Dictionary]

var should_check_kickoff_ready: bool

var player_in_control: Player

func _init() -> void:
	should_check_kickoff_ready = false
	GameEvents.team_reset.connect(on_team_reset.bind())
	player_positions = {}
	player_in_control = null

func _ready() -> void:
	country = GameManager.countries[side]
	formation = GameManager.formations[side]
	control_scheme= GameManager.control_schemes[side]
	
	target_goal.score_area.body_entered.connect(player_scored_goal.bind())
	
	time_since_last_cache_refresh = Time.get_ticks_msec()
	spawn_players()
	
func _process(_delta: float) -> void:
	if should_check_kickoff_ready:
		check_team_ready_for_kickoff()
	elif Time.get_ticks_msec() - time_since_last_cache_refresh > DURATION_WEIGHTS_CACHE:
		time_since_last_cache_refresh = Time.get_ticks_msec()
		calc_on_duty_weights()

func player_scored_goal(_ball: Ball) -> void:
	GameEvents.team_scored.emit(self)

func spawn_players() -> void:
	var players := DataLoader.get_squad(country)
	var positions := TeamFormation.get_formation_positions(
		formation,
		players
	)
	for i in players.size():
		spawn_player(positions[i], players[i])
	
func spawn_player(_position: Dictionary, _resource: PlayerResource) -> void:
	var pre_start_position := _position[TeamFormation.Mode.PreStart] as Vector2
	var post_start_position := _position[TeamFormation.Mode.PostStart] as Vector2
	var player := PLAYER_PREFAB.instantiate() as Player
	var heading := get_heading()
	
	pre_start_position = pre_start_position if side == TeamSide.Home else flip_point(pre_start_position)
	post_start_position = post_start_position if side == TeamSide.Home else flip_point(post_start_position)
	
	player.set_data(heading, pre_start_position, self, _resource)
	call_deferred("add_child", player)
	
	player_positions.set(player, {
		TeamFormation.Mode.PreStart: pre_start_position,
		TeamFormation.Mode.PostStart: post_start_position,
	})
	
func flip_point(point: Vector2) -> Vector2:
	var flip = Transform2D(Vector2(-1, 0), Vector2(0, -1), Vector2.ZERO)
	var result = flip * (point - CENTER) + CENTER
	return result

func get_player_position(mode: TeamFormation.Mode, player: Player) -> Vector2:
	assert(player_positions.has(player))
	return player_positions[player][mode]

func calc_on_duty_weights() -> void:
	var cpu_players: Array[Player] = player_positions.keys().filter(
		func (p: Player):
			return p.control_scheme == Player.ControlScheme.CPU
	)
	
	cpu_players.sort_custom(
		func (p1: Player, p2: Player):
			var p1_position := p1.position
			var p1_distance := p1_position.distance_squared_to(ball.position)
			
			var p2_position := p2.position
			var p2_distance := p2_position.distance_squared_to(ball.position)
			
			return p1_distance < p2_distance
	)

	for i in range(cpu_players.size()):
		cpu_players[i].agent.weight_on_duty_steering = 1 - ease(float(i)/15, 0.1)
		
func get_heading() -> Vector2:
	return Vector2.RIGHT if side == TeamSide.Home else Vector2.LEFT

func get_kickoff_players() -> Array[Player]:
	var players := player_positions.keys()
	players.sort_custom(
		func (p1: Player, p2: Player):
			var p1_position := get_player_position(TeamFormation.Mode.PreStart, p1)
			var p1_distance := p1_position.distance_squared_to(ball.spawn_position)
			
			var p2_position := get_player_position(TeamFormation.Mode.PreStart, p2)
			var p2_distance := p2_position.distance_squared_to(ball.spawn_position)
			
			return p1_distance < p2_distance
	)
	
	return [players[0], players[1]]

func get_reset_position(player: Player) -> Vector2:
	var kickoff_players := get_kickoff_players()
	var kickoff_idx := kickoff_players.find(player)
	
	if kickoff_idx != -1:
		var kickoff_position: Vector2 = TeamFormation.KICKOFF[kickoff_idx]
		return kickoff_position if side == TeamSide.Home else flip_point(kickoff_position)
	
	return get_player_position(TeamFormation.Mode.PreStart, player)

func on_team_reset() -> void:
	should_check_kickoff_ready = true

func check_team_ready_for_kickoff() -> void:
	for player: Player in player_positions.keys():
		if not player.is_ready_for_kickoff():
			return
	GameEvents.team_kickoff_ready.emit(self)
	should_check_kickoff_ready = false
	
func change_player_in_control(player: Player = null) -> void:
	if player_in_control != null:
		player_in_control.set_control_scheme(Player.ControlScheme.CPU)
	if player != null:
		player.set_control_scheme(control_scheme)
	player_in_control = player
	
func set_nearest_player_in_control() -> void:
	var players := player_positions.keys()
	players.sort_custom(
		func (p1: Player, p2: Player):
			var p1_position := p1.position
			var p1_distance := p1_position.distance_squared_to(ball.position)
			
			var p2_position := p2.position
			var p2_distance := p2_position.distance_squared_to(ball.position)
			
			return p1_distance < p2_distance
	)
	for player: Player in players:
		if player != player_in_control:
			change_player_in_control(player)
			break

func has_ball() -> bool:
	for player: Player in player_positions.keys():
		if player.has_ball():
			return true
	return false
