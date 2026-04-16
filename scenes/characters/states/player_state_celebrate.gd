class_name PlayerStateCelebrate
extends PlayerState

const HEIGHT := 0.1
const HEIGHT_VELOCITY := 1.5
const AIR_FRICTION := 35.0

func _enter_tree() -> void:
	celebrate()
	GameEvents.team_reset.connect(on_team_reset.bind())
	
func _process(delta: float) -> void:
	if player.height == 0:
		celebrate()
	player.velocity = player.velocity.move_toward(Vector2.ZERO, AIR_FRICTION*delta)

func celebrate() -> void:
	animation_player.play("Celebrate")
	player.height = HEIGHT
	player.height_velocity = HEIGHT_VELOCITY

func on_team_reset() -> void:
	var reset_position := player.get_formation_position(TeamFormation.Mode.PreStart)
	var _data := PlayerStateData.build().set_reset_position(reset_position)
	state_transition(Player.State.RESETING, _data)

func can_carry_ball() -> bool:
	return false
