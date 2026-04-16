class_name PlayerStatePrepKick
extends PlayerState

const DURATION_MAX_BONUS := 1000
const EASE_REWARD_FACTOR := 2

var start_time_kick: int
var kick_direction: Vector2

func _enter_tree() -> void:
	animation_player.play("PrepKick")
	player.velocity = Vector2.ZERO
	kick_direction = player.heading
	start_time_kick = Time.get_ticks_msec()

func _process(delta: float) -> void:
	kick_direction += KeyUtils.get_input_vector(player.control_scheme)*delta
	
	if KeyUtils.is_action_just_released(player.control_scheme, KeyUtils.Action.SHOOT):
		var duration := clampf(Time.get_ticks_msec()-start_time_kick, 0, DURATION_MAX_BONUS)
		var ease_time := duration/DURATION_MAX_BONUS
		var bonus := ease(ease_time, EASE_REWARD_FACTOR)
		var kick_power := player.power*(1+bonus)
		
		kick_direction = kick_direction.normalized()
		
		var _data := (
			PlayerStateData
				.build()
				.set_kick_direction(kick_direction)
				.set_kick_power(kick_power)
		)
		
		state_transition(Player.State.KICK, _data)
