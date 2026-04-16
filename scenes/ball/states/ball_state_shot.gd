class_name BallStateShot
extends BallState

const KICK_SPRITE_FREQUENCY := 10
const KICK_SPRITE_INTENSITY := 0.9
const KICK_SPRITE_MIN_HEIGHT := 0.7
const KICK_HEIGHT := 30
const KICK_DURATION := 1000
const KICK_HEIGHT_SCALE := 5

var kick_time: float
var time_since_kick: int

func _enter_tree() -> void:
	animation_player.play("Roll")
	kick_time = 0
	time_since_kick = Time.get_ticks_msec()
	shot_particles.emitting = true
	GameEvents.impact_received.emit(ball.position, true)

func _process(delta: float) -> void:
	shot_particles.position.y = -ball.height
	if Time.get_ticks_msec() - time_since_kick > KICK_DURATION:
		state_transition_requested.emit(Ball.State.FREEFORM)
	
	ball.move_and_bounce(delta, Ball.BOUNCINESS)
	kick_time += delta
	ball_sprite.scale.y = max(abs(cos(kick_time*KICK_SPRITE_FREQUENCY))*KICK_SPRITE_INTENSITY, KICK_SPRITE_MIN_HEIGHT)
	ball.height = lerpf(ball.height, KICK_HEIGHT, KICK_HEIGHT_SCALE*delta)

func _exit_tree() -> void:
	ball_sprite.scale.y = 1.0
	shot_particles.emitting = false

func can_air_interact() -> bool:
	return ball.height > 0
