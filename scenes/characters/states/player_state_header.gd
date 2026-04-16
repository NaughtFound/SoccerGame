class_name PlayerStateHeader
extends PlayerState

const AIR_CONNECT_MIN_HEIGHT := 10
const AIR_CONNECT_MAX_HEIGHT := 30
const HEIGHT_START := 0.1
const HEIGHT_VELOCITY := 1.5
const BONUS_POWER := 1.3

func _enter_tree() -> void:
	animation_player.play("Header")
	player.height = HEIGHT_START
	player.height_velocity = HEIGHT_VELOCITY
	ball_detection_area.body_entered.connect(on_ball_entered.bind())

func on_ball_entered(_ball: Ball) -> void:
	if _ball.can_air_connect(AIR_CONNECT_MIN_HEIGHT, AIR_CONNECT_MAX_HEIGHT):
		SoundPlayer.play(SoundPlayer.Sound.POWERSHOT)
		_ball.shoot(player.velocity.normalized()*player.power*BONUS_POWER)

func _process(_delta: float) -> void:
	if player.height == 0:
		state_transition(Player.State.RECOVERING)
