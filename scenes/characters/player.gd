class_name Player
extends CharacterBody2D

const GRAVITY := 6.0
const CONTROL_BALL_MAX_HEIGHT := 10
const WALK_THRESHOLD := 0.6

const CONTROL_SCHEME_MAP: Dictionary = {
	ControlScheme.CPU: preload("res://assets/art/props/cpu.png"),
	ControlScheme.P1: preload("res://assets/art/props/1p.png"),
	ControlScheme.P2: preload("res://assets/art/props/2p.png"),
}

enum Role {GK, CB, RB, LB, CM, LW, RW, ST}
enum SkinColor {LIGHT, MEDIUM, DARK}
enum ControlScheme {P1, P2, CPU}
enum State {
	MOVING,
	TACKLING,
	RECOVERING,
	PREPKICK,
	KICK,
	PASS,
	BICYCLEKICK,
	VOLLEYKICK,
	HEADER,
	CHESTCONTROL,
	HURT,
	DIVE,
	CELEBRATNG,
	MOURNING,
	RESETING
}

@export var ball: Ball
@export var own_goal: Goal
@export var target_goal: Goal
@export var control_scheme: ControlScheme
@export var team: Team

@export_category("Player Information")
@export var country: String
@export var full_name: String
@export var skin_color: Player.SkinColor
@export var role: Player.Role
@export var speed: float
@export var power: float

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player_sprite: Sprite2D = %PlayerSprite
@onready var teammate_detection_area: Area2D = %TeammateDetectionArea
@onready var control_sprite: Sprite2D = %ControlSprite
@onready var ball_detection_area: Area2D = %BallDetectionArea
@onready var tackle_detection_area: Area2D = %TackleDetectionArea
@onready var player_body_collision: CollisionShape2D = %PlayerBodyCollision
@onready var root_particles: Node2D = %RootParticles
@onready var run_particles: GPUParticles2D = %RunParticles

var agent: PlayerAgent
var current_state: PlayerState
var state_factory: PlayerStateFactory
var heading: Vector2
var height: float
var height_velocity: float

func _init() -> void:
	agent = null
	current_state = null
	state_factory = PlayerStateFactory.new()
	heading = Vector2.RIGHT
	height = 0.0
	height_velocity = 0.0
	GameEvents.team_scored.connect(on_team_scored.bind())
	GameEvents.team_reset.connect(on_team_reset.bind())
	GameEvents.game_over.connect(on_game_over.bind())

func _ready() -> void:
	set_shader_properties()
	set_control_texture()
	setup_agent()
	set_init_state()
	

func _process(delta: float) -> void:
	set_heading()
	flip_sprite()
	set_height()
	apply_gravity(delta)
	set_control_visibility()
	set_particles_visibility()
	move_and_slide()
	
func set_init_state() -> void:
	var reset_position := get_formation_position(TeamFormation.Mode.PreStart)
	
	if team.side == Team.TeamSide.Home:
		reset_position = get_reset_position()
	
	var data := PlayerStateData.build().set_reset_position(reset_position)
	switch_state(State.RESETING, data)

func set_data(
	_heading: Vector2,
	_position: Vector2,
	_team: Team,
	_resource: PlayerResource
) -> void:
	heading = _heading
	position = _position
	team = _team
	ball = _team.ball
	own_goal = _team.own_goal
	target_goal = _team.target_goal
	country = _resource.country
	full_name = _resource.full_name
	skin_color = _resource.skin_color
	role = _resource.role
	speed = _resource.speed
	power = _resource.power
	
func set_movement_animation() -> void:
	var len_v := velocity.length()
	if len_v < 1:
		animation_player.play("Idle")
	elif len_v < speed * WALK_THRESHOLD:
		animation_player.play("Walk")
	else:
		animation_player.play("Run")
		
	
func setup_agent() -> void:
	agent = PlayerAgent.new(self, ball)
	call_deferred("add_child", agent)

func switch_state(state: State, data: PlayerStateData = null) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self, data)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "PlayerStateMachine"
	call_deferred("add_child", current_state)

func set_shader_properties() -> void:
	var country_idx := DataLoader.countries.find(country)+1
	player_sprite.material.set_shader_parameter("team_color", country_idx)
	player_sprite.material.set_shader_parameter("skin_color", skin_color)

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT
	
	if velocity.length() >= 1:
		teammate_detection_area.rotation = velocity.angle()
	else:
		teammate_detection_area.rotation = heading.angle()

func flip_sprite() -> void:
	if heading == Vector2.RIGHT:
		player_sprite.flip_h = false
		tackle_detection_area.scale.x = 1.0
		root_particles.scale.x = 1.0
	elif heading == Vector2.LEFT:
		player_sprite.flip_h = true
		tackle_detection_area.scale.x = -1.0
		root_particles.scale.x = -1.0

func set_height() -> void:
	player_sprite.position = Vector2.UP*height

func has_ball() -> bool:
	return ball.carrier == self

func on_animation_complete() -> void:
	if current_state != null:
		current_state.on_animation_complete()

func set_control_texture() -> void:
	if control_sprite != null:
		control_sprite.texture = CONTROL_SCHEME_MAP[control_scheme]

func set_control_visibility() -> void:
	if control_scheme == ControlScheme.CPU:
		control_sprite.visible = has_ball()
	else:
		control_sprite.visible = true

func set_particles_visibility() -> void:
	run_particles.emitting = velocity.length() == speed

func apply_gravity(delta:float) -> void:
	if height > 0 or height_velocity > 0:
		height_velocity -= GRAVITY*delta
		height += height_velocity
	
	if height < 0:
		height = 0
	
func control_ball() -> void:
	if has_ball() and ball.height > CONTROL_BALL_MAX_HEIGHT:
		switch_state(State.CHESTCONTROL)

func get_hurt(_direction: Vector2) -> void:
	var _data := PlayerStateData.build().set_hurt_direction(_direction)
	switch_state(State.HURT, _data)

func get_formation_position(mode:TeamFormation.Mode) -> Vector2:
	return team.get_player_position(mode, self)
	
func get_reset_position() -> Vector2:
	return team.get_reset_position(self)

func can_carry_ball() -> bool:
	return current_state != null and current_state.can_carry_ball()

func is_ready_for_kickoff() -> bool:
	return current_state != null and current_state.is_ready_for_kickoff()
	
func set_control_scheme(scheme: ControlScheme) -> void:
	control_scheme = scheme
	set_control_texture()

func on_team_scored(_team: Team) -> void:
	if team == _team:
		switch_state(State.CELEBRATNG)
	else:
		switch_state(State.MOURNING)

func on_team_reset() -> void:
	set_control_texture()

func on_game_over() -> void:
	if team.side == GameManager.get_winner_side():
		switch_state(State.CELEBRATNG)
	else:
		switch_state(State.MOURNING)
