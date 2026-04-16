class_name ScreenFactory

var states: Dictionary

func _init() -> void:
	states = {
		SoccerGame.ScreenType.MAIN_MENU: preload("res://scenes/screens/main_menu/main_menu_screen.tscn"),
		SoccerGame.ScreenType.TEAM_SELECTION: preload("res://scenes/screens/team_selection/select_team_screen.tscn"),
		SoccerGame.ScreenType.FORMATION_SELECTION: preload("res://scenes/screens/formation_selection/select_formation_screen.tscn"),
		SoccerGame.ScreenType.IN_GAME: preload("res://scenes/screens/world/world_screen.tscn"),
	}

func get_fresh_screen(screen: SoccerGame.ScreenType) -> Screen:
	assert(states.has(screen), "State doesn't exists!")
	return states[screen].instantiate()
