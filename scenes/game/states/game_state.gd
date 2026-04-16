class_name GameState
extends Node

signal state_transition_requested(new_state: GameManager.State)

var manager: GameManager = null
var data: GameStateData = null

func setup(_manager: GameManager, _data: GameStateData) -> void:
	manager = _manager
	data = _data

func state_transition(new_state:GameManager.State, _data: GameStateData=null)-> void:
	state_transition_requested.emit(new_state, _data)
