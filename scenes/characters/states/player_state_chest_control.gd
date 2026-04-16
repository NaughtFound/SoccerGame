class_name PlayerStateChestControl
extends PlayerState

const CONTROL_DURATION := 500

var time_start_control: int

func _enter_tree() -> void:
	animation_player.play("ChestControl")
	player.velocity = Vector2.ZERO
	time_start_control = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_start_control >= CONTROL_DURATION:
		state_transition(Player.State.MOVING)
