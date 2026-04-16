class_name PlayerStateDive
extends PlayerState

const DIVE_DURATION := 500

var time_since_dive: int

func _enter_tree() -> void:
	player.player_body_collision.disabled = false
	var target := Vector2(player.position.x, ball.position.y)
	var direction := player.position.direction_to(target)
	
	if direction.y > 0:
		animation_player.play("DiveDown")
	else:
		animation_player.play("DiveUp")
	player.velocity = direction*player.speed
	time_since_dive = Time.get_ticks_msec()

func _exit_tree() -> void:
	player.player_body_collision.disabled = true

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_dive > DIVE_DURATION:
		state_transition(Player.State.RECOVERING)

func can_carry_ball() -> bool:
	return false
