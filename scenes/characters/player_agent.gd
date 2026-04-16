class_name PlayerAgent
extends Node2D

const DURATION_AI_TICK_FREQUENCY := 500
const GOAL_INTERNAL_RADIUS := 150.0
const GOAL_EXTERNAL_RADIUS := 250.0
const TEAMMATE_INTERNAL_RADIUS := 25.0
const TEAMMATE_EXTERNAL_RADIUS := 50.0
const BALL_INTERNAL_RADIUS := 25.0
const BALL_EXTERNAL_RADIUS := 90.0
const FORMATION_INTERNAL_RADIUS := 30.0
const FORMATION_EXTERNAL_RADIUS := 100.0

const KICK_PROBABILITY := {
	Player.Role.GK: 0.4,
	Player.Role.CB: 0.5,
	Player.Role.LB: 0.3,
	Player.Role.RB: 0.3,
	Player.Role.CM: 0.4,
	Player.Role.LW: 0.5,
	Player.Role.RW: 0.5,
	Player.Role.ST: 0.7
}
const TACKLE_PROBABILITY := {
	Player.Role.GK: 0.1,
	Player.Role.CB: 0.6,
	Player.Role.LB: 0.6,
	Player.Role.RB: 0.6,
	Player.Role.CM: 0.5,
	Player.Role.LW: 0.4,
	Player.Role.RW: 0.4,
	Player.Role.ST: 0.3
}
const PASS_PROBABILITY := {
	Player.Role.GK: 0.8,
	Player.Role.CB: 0.6,
	Player.Role.LB: 0.6,
	Player.Role.RB: 0.6,
	Player.Role.CM: 0.5,
	Player.Role.LW: 0.4,
	Player.Role.RW: 0.4,
	Player.Role.ST: 0.3
}

var role_action_mapping: Dictionary[Player.Role, PlayerAction]
var player: Player
var ball: Ball
var time_since_last_tick: int

var weight_on_duty_steering: float

func _init(_player: Player, _ball: Ball) -> void:
	player = _player
	ball = _ball
	time_since_last_tick = 0
	weight_on_duty_steering = 0
	role_action_mapping = {
		Player.Role.GK: PlayerActionGK.new(self)
	}

func _ready() -> void:
	time_since_last_tick = Time.get_ticks_msec() + randi_range(0, DURATION_AI_TICK_FREQUENCY)
	
func make_decisions() -> void:
	if Time.get_ticks_msec() - time_since_last_tick > DURATION_AI_TICK_FREQUENCY:
		time_since_last_tick = Time.get_ticks_msec()
		perform_ai_movement()
		perform_ai_decisions()
		
func perform_ai_movement() -> void:
	var steering_force := Vector2.ZERO
	var role_action: PlayerAction = role_action_mapping.get(player.role)
	if role_action != null:
		steering_force += role_action.calc_steering_force()
	else:
		steering_force += calc_on_duty_steering_force()
		steering_force += calc_carrier_steering_force()
		steering_force += calc_teammate_steering_force()
		steering_force += calc_formation_steering_force()
		steering_force = steering_force.limit_length(1.0)
	
	player.velocity = steering_force*player.speed
	
	if player.velocity.length() < 1:
		player.heading = player.team.get_heading()

func perform_ai_decisions() -> void:
	var role_action: PlayerAction = role_action_mapping.get(player.role)
	if role_action != null:
		role_action.do()
	else:
		do_kick()
		do_tackle()
		do_pass()
		
func do_kick() -> void:
	if not player.has_ball():
		return
	
	var rnd := randf()
	var target := player.target_goal.get_random_target()
	var weight := calc_bicircular_weight(
		player.position,
		target,
		GOAL_INTERNAL_RADIUS,
		1.0,
		GOAL_EXTERNAL_RADIUS,
		0.5
	)
	
	if rnd*weight < (1-KICK_PROBABILITY[player.role]):
		return
	
	var data := (
		PlayerStateData
			.build()
			.set_kick_direction(player.position.direction_to(target))
			.set_kick_power(player.power*2*weight)
	)
	
	player.switch_state(Player.State.KICK, data)

func do_tackle() -> void:
	if not is_ball_carried_by_opponent():
		return

	var rnd := randf()
	var weight := calc_bicircular_weight(
		player.position,
		ball.position,
		BALL_INTERNAL_RADIUS,
		1.0,
		BALL_EXTERNAL_RADIUS,
		0.0
	)
	
	if rnd*weight < (1-TACKLE_PROBABILITY[player.role]):
		return
	
	player.switch_state(Player.State.TACKLING)

func do_pass() -> void:
	if not player.has_ball():
		return
	
	var rnd := randf()
	var target := player.get_formation_position(TeamFormation.Mode.PostStart)
	var weight := calc_bicircular_weight(
		player.position,
		target,
		FORMATION_INTERNAL_RADIUS,
		0.0,
		FORMATION_EXTERNAL_RADIUS,
		1.0
	)
	
	if rnd*weight < (1-PASS_PROBABILITY[player.role]):
		return
	
	player.switch_state(Player.State.PASS)

func calc_on_duty_steering_force() -> Vector2:
	if player.has_ball() or is_ball_carried_by_teammate():
		return Vector2.ZERO
	
	var direction := player.position.direction_to(ball.position)
	return direction*weight_on_duty_steering

func calc_carrier_steering_force() -> Vector2:
	if not player.has_ball():
		return Vector2.ZERO
		
	var target := player.target_goal.get_random_target()
	var direction := player.position.direction_to(target)
	var weight := calc_bicircular_weight(
		player.position,
		target,
		GOAL_INTERNAL_RADIUS,
		0.0,
		GOAL_EXTERNAL_RADIUS,
		1.0
	)
	return direction*weight

func calc_teammate_steering_force() -> Vector2:
	if not is_ball_carried_by_teammate():
		return Vector2.ZERO
	
	var player_position := player.get_formation_position(TeamFormation.Mode.PostStart)
	var distance_proba := calc_distance_proba_to_formation(TeamFormation.Mode.PostStart)
	var assist_destination := (
		player_position*distance_proba+
		ball.carrier.position*(1-distance_proba)
	)
	var direction := player.position.direction_to(assist_destination)
	var weight := calc_bicircular_weight(
		player.position,
		assist_destination,
		TEAMMATE_INTERNAL_RADIUS,
		0.2,
		TEAMMATE_EXTERNAL_RADIUS,
		1.0
	)
	return direction*weight

func calc_formation_steering_force() -> Vector2:
	if player.has_ball():
		return Vector2.ZERO
	
	var target := player.get_formation_position(TeamFormation.Mode.PostStart)
	var direction := player.position.direction_to(target)
	return direction*(1-weight_on_duty_steering)

func calc_bicircular_weight(
	source: Vector2,
	target: Vector2,
	r_int: float,
	w_int: float,
	r_ext: float,
	w_ext: float,
) -> float:
	var distance := source.distance_to(target)
	if distance >= r_ext:
		return w_ext
	elif distance <= r_int:
		return w_int
	
	var weight := (distance-r_int)/(r_ext-r_int)
	
	return lerpf(w_int, w_ext, weight)

func is_ball_carried_by_teammate() -> bool:
	return not player.has_ball() and ball.carrier != null and ball.carrier.team == player.team

func is_ball_carried_by_opponent() -> bool:
	return not player.has_ball() and ball.carrier != null and ball.carrier.team != player.team

func calc_distance_proba_to_formation(mode: TeamFormation.Mode) -> float:
	var target := player.get_formation_position(mode)
	var weight := calc_bicircular_weight(
		player.position,
		target,
		FORMATION_INTERNAL_RADIUS,
		1.0,
		FORMATION_EXTERNAL_RADIUS,
		0.0
	)
	return weight
