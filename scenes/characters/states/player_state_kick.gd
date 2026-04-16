class_name PlayerStateKick
extends PlayerState

func _enter_tree() -> void:
	animation_player.play("Kick")
	SoundPlayer.play(SoundPlayer.Sound.SHOOT)
	
func on_animation_complete() -> void:
	state_transition(Player.State.MOVING)
	shoot_ball()

func shoot_ball() -> void:
	assert(data != null)

	if player.has_ball():
		ball.shoot(data.kick_direction*data.kick_power)
