class_name BallState
extends Node

signal state_transition_requested(new_state: Ball.State)

var ball : Ball = null
var ball_sprite: Sprite2D = null
var player_detection_area: Area2D = null
var animation_player: AnimationPlayer = null
var carrier: Player = null
var shot_particles: GPUParticles2D = null

func setup(_ball: Ball) -> void:
	ball = _ball
	ball_sprite = _ball.ball_sprite
	player_detection_area = _ball.player_detection_area
	animation_player = _ball.animation_player
	carrier = _ball.carrier
	shot_particles = _ball.shot_particles

func can_air_interact() -> bool:
	return false
