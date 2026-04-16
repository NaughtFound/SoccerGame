class_name PlayerStateReset
extends PlayerState

const MAX_DISTANCE := 2

var has_arrived: bool

func _enter_tree() -> void:
	assert(data != null)
	GameEvents.kickoff_started.connect(on_kickoff_started.bind())

func _process(_delta: float) -> void:
	var distance := player.position.distance_to(data.reset_position)
	var direction := player.position.direction_to(data.reset_position)
	if distance < MAX_DISTANCE:
		has_arrived = true
		player.velocity = Vector2.ZERO
		player.heading = player.team.get_heading()
	else:
		player.velocity = direction*player.speed
	player.set_movement_animation()

func is_ready_for_kickoff() -> bool:
	return has_arrived

func on_kickoff_started() -> void:
	state_transition(Player.State.MOVING)

func can_carry_ball() -> bool:
	return false
