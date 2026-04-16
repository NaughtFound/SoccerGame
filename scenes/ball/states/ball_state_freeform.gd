class_name BallStateFreeform
extends BallState

const BALL_MIN_AIR_HEIGHT := 5

func _enter_tree() -> void:
	ball.carrier = null
	player_detection_area.body_entered.connect(on_player_entered.bind())

func _exit_tree() -> void:
	animation_player.speed_scale = 1.0

func _process(delta: float) -> void:
	if ball.velocity == Vector2.ZERO:
		animation_player.play("Idle")
		animation_player.speed_scale = 1.0
	else:
		animation_player.play("Roll")
		animation_player.speed_scale = ball.velocity.normalized().length()
	
	var friction := Ball.AIR_FRICTION if ball.height > 0 else Ball.GROUND_FRICTION
	ball.velocity = ball.velocity.move_toward(Vector2.ZERO, friction*delta)
	ball.move_and_bounce(delta, Ball.BOUNCINESS)
	ball.apply_gravity(delta, Ball.BOUNCINESS)

func on_player_entered(_player: Player) -> void:
	if _player.can_carry_ball():
		ball.carrier = _player
		_player.control_ball()
		state_transition_requested.emit(Ball.State.CARRIED)

func can_air_interact() -> bool:
	return ball.height > BALL_MIN_AIR_HEIGHT
