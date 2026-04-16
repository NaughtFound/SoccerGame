class_name PlayerStateRecovering
extends PlayerState

const RECOVERY_DURATION := 500
var time_start_recovery : float

func _enter_tree() -> void:
	time_start_recovery = Time.get_ticks_msec()
	player.velocity = Vector2.ZERO
	animation_player.play("Recover")

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_start_recovery >= RECOVERY_DURATION:
		state_transition(Player.State.MOVING)

func can_carry_ball() -> bool:
	return false
