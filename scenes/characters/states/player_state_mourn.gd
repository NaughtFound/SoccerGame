class_name PlayerStateMourn
extends PlayerState

func _enter_tree() -> void:
	animation_player.play("Mourn")
	player.velocity = Vector2.ZERO
	GameEvents.team_reset.connect(on_team_reset.bind())
	
func on_team_reset() -> void:
	var reset_position := player.get_reset_position()
	var _data := PlayerStateData.build().set_reset_position(reset_position)
	state_transition(Player.State.RESETING, _data)

func can_carry_ball() -> bool:
	return false
