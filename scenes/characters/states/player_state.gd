class_name PlayerState
extends Node

signal state_transition_requested(new_state: Player.State, data: PlayerStateData)

var player: Player = null
var agent: PlayerAgent = null
var ball: Ball = null
var data: PlayerStateData = null
var animation_player: AnimationPlayer = null
var teammate_detection_area: Area2D = null
var ball_detection_area: Area2D = null
var tackle_detection_area: Area2D = null

func setup(_player: Player, _data: PlayerStateData) -> void:
	player = _player
	agent = _player.agent
	ball = _player.ball
	animation_player = _player.animation_player
	teammate_detection_area = _player.teammate_detection_area
	ball_detection_area = _player.ball_detection_area
	tackle_detection_area = _player.tackle_detection_area
	data = _data

func state_transition(new_state:Player.State, _data: PlayerStateData=null)-> void:
	state_transition_requested.emit(new_state, _data)

func on_animation_complete() -> void:
	pass

func can_carry_ball() -> bool:
	return true
	
func is_ready_for_kickoff() -> bool:
	return false
