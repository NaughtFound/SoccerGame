class_name BallStateCarried
extends BallState

const OFFSET := Vector2(10, 2.5)
const DRIBBLE_FREQUENCY := 10
const DRIBBLE_INTENSITY := 3

var dribble_time: float

func _enter_tree() -> void:
	assert(carrier != null)
	dribble_time = 0
	carrier.team.change_player_in_control(carrier)
	GameEvents.ball_carried.emit(carrier)

func _exit_tree() -> void:
	carrier.team.change_player_in_control()
	GameEvents.ball_released.emit()

func _process(delta: float) -> void:
	var vx := 0.0
	dribble_time += delta
	
	var speed := carrier.velocity.length()/carrier.speed
	
	if carrier.velocity.length() > 0:
		if carrier.velocity.x != 0:
			vx = cos(dribble_time*DRIBBLE_FREQUENCY)*DRIBBLE_INTENSITY*speed
		animation_player.play("Roll")
		animation_player.speed_scale = speed
	else:
		animation_player.play("Idle")
		animation_player.speed_scale = 1.0
	
	ball.velocity = carrier.velocity
	ball.position = carrier.position + Vector2(vx+carrier.heading.x*OFFSET.x,OFFSET.y)
	ball.apply_gravity(delta)
