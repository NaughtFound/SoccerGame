class_name Goal
extends Node2D

@onready var back_net_area: Area2D = %BackNetArea
@onready var score_area: Area2D = %ScoreArea
@onready var back_net_region: CollisionPolygon2D = %CollisionPolygon2D

func _ready() -> void:
	back_net_area.body_entered.connect(on_ball_enter_back_net.bind())
	score_area.body_entered.connect(on_ball_enter_score_area.bind())

func on_ball_enter_back_net(ball: Ball) -> void:
	ball.stop()

func on_ball_enter_score_area(_ball: Ball) -> void:
	SoundPlayer.play(SoundPlayer.Sound.WHISTLE)

func get_random_target() -> Vector2:
	var p = back_net_region.polygon
	
	var i = randi() % p.size()
	var a = p[i]
	var b = p[(i + 1) % p.size()]
	
	var point = a.lerp(b, randf())
	
	return back_net_region.to_global(point)
