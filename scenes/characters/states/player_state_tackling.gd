class_name PlayerStateTackling
extends PlayerState

const TACKLE_DURATION := 200
const GROUND_FRICTION := 250

var is_tackle_complete: bool
var time_finish_tackle: float

func _enter_tree() -> void:
	animation_player.play("Tackle")
	tackle_detection_area.monitoring = true
	tackle_detection_area.body_entered.connect(on_player_entered.bind())
	is_tackle_complete = false

func _exit_tree() -> void:
	tackle_detection_area.monitoring = false

func _process(delta: float) -> void:
	if not is_tackle_complete:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, GROUND_FRICTION*delta)
		if player.velocity == Vector2.ZERO:
			is_tackle_complete = true
			time_finish_tackle = Time.get_ticks_msec()
	
	elif Time.get_ticks_msec() - time_finish_tackle >= TACKLE_DURATION:
		state_transition(Player.State.RECOVERING)

func on_player_entered(_player: Player) -> void:
	if _player != player:
		_player.get_hurt(player.position.direction_to(_player.position))
