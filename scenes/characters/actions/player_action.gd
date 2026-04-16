@abstract class_name PlayerAction

var agent: PlayerAgent
var player: Player
var ball: Ball

func _init(_agent: PlayerAgent) -> void:
	agent = _agent
	player = _agent.player
	ball = _agent.ball

@abstract func do() -> void
@abstract func calc_steering_force() -> Vector2
