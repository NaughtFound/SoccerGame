class_name PlayerStateVolleyKick
extends PlayerState

const AIR_CONNECT_MIN_HEIGHT := 1
const AIR_CONNECT_MAX_HEIGHT := 20
const BONUS_POWER := 1.5

func _enter_tree() -> void:
	animation_player.play("VolleyKick")
	ball_detection_area.body_entered.connect(on_ball_entered.bind())

func on_animation_complete() -> void:
	state_transition(Player.State.RECOVERING)
	
func on_ball_entered(_ball: Ball) -> void:
	if _ball.can_air_connect(AIR_CONNECT_MIN_HEIGHT, AIR_CONNECT_MAX_HEIGHT):
		var destination := get_facing_goal().get_random_target()
		var direction := ball.position.direction_to(destination)
		SoundPlayer.play(SoundPlayer.Sound.POWERSHOT)
		_ball.shoot(direction*player.power*BONUS_POWER)

func get_facing_goal() -> Goal:
	var direction := player.position.direction_to(player.target_goal.position)
	
	if player.heading.dot(direction) >= 0:
		return player.target_goal
	else:
		return player.own_goal
