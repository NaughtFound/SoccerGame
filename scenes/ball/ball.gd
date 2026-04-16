class_name Ball
extends AnimatableBody2D

enum State {CARRIED, FREEFORM, SHOT}

const GRAVITY := 10.0
const AIR_FRICTION := 35
const GROUND_FRICTION := 350
const BOUNCINESS := 0.8
const SHORT_PASS_LIMIT := 130
const TUMBLE_HEIGHT_VELOCITY := 2.0

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player_detection_area: Area2D = %PlayerDetectionArea
@onready var ball_sprite: Sprite2D = %BallSprite
@onready var kick_raycast: RayCast2D = %KickRayCast
@onready var shot_particles: GPUParticles2D = %ShotParticles

var carrier: Player = null
var velocity: Vector2
var height_velocity: float
var current_state: BallState = null
var state_factory: BallStateFactory = null
var height: float
var spawn_position: Vector2

func _init() -> void:
	state_factory = BallStateFactory.new()
	velocity = Vector2.ZERO
	height = 0.0
	height_velocity = 0.0
	GameEvents.team_reset.connect(on_team_reset.bind())

func _process(_delta: float) -> void:
	set_height()
	flip_sprite()

func _ready() -> void:
	switch_state(State.FREEFORM)
	spawn_position = position
	
func on_team_reset() -> void:
	position = spawn_position
	velocity = Vector2.ZERO
	switch_state(State.FREEFORM)

func switch_state(state: State) -> void:
	if current_state != null:
		current_state.queue_free()
	current_state = state_factory.get_fresh_state(state)
	current_state.setup(self)
	current_state.state_transition_requested.connect(switch_state.bind())
	current_state.name = "BallStateMachine"
	call_deferred("add_child", current_state)

func set_height() -> void:
	ball_sprite.position = Vector2.UP*height

func apply_gravity(delta:float, bounciness: float = 0.0) -> void:
	if height > 0 or height_velocity > 0:
		height_velocity -= GRAVITY*delta
		height += height_velocity 
	if height < 0:
		height = 0
		if bounciness > 0 and height_velocity < 0:
			height_velocity = -height_velocity*bounciness
			velocity *= bounciness
	
func flip_sprite() -> void:
	if velocity.x > 0:
		ball_sprite.flip_h = false
	elif velocity.x < 0:
		ball_sprite.flip_h = true
	
	if velocity.length() >= 1:
		kick_raycast.rotation = velocity.angle()
		
func shoot(_velocity: Vector2) -> void:
	velocity = _velocity
	carrier = null
	switch_state(State.SHOT)
	
func tumble(_velocity: Vector2) -> void:
	velocity = _velocity
	carrier = null
	height_velocity = TUMBLE_HEIGHT_VELOCITY
	switch_state(State.FREEFORM)

func pass_to(_destination: Vector2) -> void:
	var direction := position.direction_to(_destination)
	var distance := position.distance_to(_destination)
	var intensity := sqrt(2*distance*GROUND_FRICTION)
	velocity = intensity*direction
	if distance >= SHORT_PASS_LIMIT:
		height_velocity = GRAVITY*distance/(1.8*intensity)
	carrier = null
	switch_state(State.FREEFORM)

func stop() -> void:
	velocity = Vector2.ZERO
	
func move_and_bounce(delta: float, bounciness:float = 0.0) -> void:
	var collision := move_and_collide(velocity*delta)
	if collision != null:
		SoundPlayer.play(SoundPlayer.Sound.BOUNCE)
		velocity = velocity.bounce(collision.get_normal())*bounciness
		switch_state(State.FREEFORM)

func can_air_interact() -> bool:
	return current_state != null and current_state.can_air_interact()

func can_air_connect(min_height: float, max_height: float) -> bool:
	return height >= min_height and height <= max_height

func is_headed_for_scoring_area() -> bool:
	return kick_raycast.is_colliding()
