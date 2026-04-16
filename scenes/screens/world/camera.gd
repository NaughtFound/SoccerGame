class_name Camera
extends Camera2D

const DISTANCE_TARGET := 100
const BALL_CARRIED_SMOOTHING := 1
const BALL_DEFAULT_SMOOTHING := 8
const SHAKE_DURATION := 200
const SHAKE_INTENSITY := 2.0

@export var ball: Ball

var is_shaking: bool
var time_since_shake: int

func _init() -> void:
	GameEvents.impact_received.connect(on_impact_received.bind())

func _ready() -> void:
	time_since_shake = 0
	is_shaking = false 

func _process(_delta: float) -> void:
	if ball.carrier != null:
		position = ball.carrier.position+ball.carrier.heading*DISTANCE_TARGET
		position_smoothing_speed = BALL_CARRIED_SMOOTHING
	else:
		position = ball.position
		position_smoothing_speed = BALL_DEFAULT_SMOOTHING
		
	if is_shaking and Time.get_ticks_msec() - time_since_shake < SHAKE_DURATION:
		offset = Vector2(randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY), randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY))
	else:
		offset = Vector2.ZERO

func on_impact_received(_position: Vector2, _is_high: bool) -> void:
	is_shaking = _is_high
	if is_shaking:
		time_since_shake = Time.get_ticks_msec()
