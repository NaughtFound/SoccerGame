class_name Screen
extends Node

signal screen_transition_requested(new_screen: SoccerGame.ScreenType, data: ScreenData)

var game: SoccerGame = null
var data: ScreenData = null

func setup(_game: SoccerGame, _data: ScreenData) -> void:
	game = _game
	data = _data

func screen_transition(new_screen: SoccerGame.ScreenType, _data: ScreenData=null) -> void:
	screen_transition_requested.emit(new_screen, _data)

func go_back() -> void:
	if data == null:
		return
	SoundPlayer.play(SoundPlayer.Sound.UI_NAV)
	screen_transition(data.former_screen)
