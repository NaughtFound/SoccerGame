class_name PlayerStateHurt
extends PlayerState

const HURT_DURATION := 1000
const AIR_FRICTION := 35
const HEIGHT_START := 0.1
const HEIGHT_VELOCITY := 0.5
const BALL_TUMBLE_SPEED := 50

var time_start_hurt: int

func _enter_tree() -> void:
	assert(data != null)
	
	animation_player.play("Hurt")
	time_start_hurt = Time.get_ticks_msec()
	player.height = HEIGHT_START
	player.height_velocity = HEIGHT_VELOCITY
	if player.has_ball():
		ball.tumble(data.hurt_direction*BALL_TUMBLE_SPEED)
		SoundPlayer.play(SoundPlayer.Sound.HURT)
		GameEvents.impact_received.emit(player.position, false)
	
func _process(delta: float) -> void:
	if Time.get_ticks_msec() - time_start_hurt >= HURT_DURATION:
		state_transition(Player.State.RECOVERING)
	
	player.velocity = player.velocity.move_toward(Vector2.ZERO, AIR_FRICTION*delta)
