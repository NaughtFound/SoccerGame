class_name SoccerGame
extends Node

enum ScreenType {
	MAIN_MENU,
	TEAM_SELECTION,
	FORMATION_SELECTION,
	IN_GAME
}

var screen_factory: ScreenFactory
var current_screen: Screen

func _init() -> void:
	screen_factory = ScreenFactory.new()
	current_screen = null
	
func  _ready() -> void:
	switch_screen(ScreenType.MAIN_MENU)

func switch_screen(screen: ScreenType, data: ScreenData = null) -> void:
	if data == null:
		data = ScreenData.build()
	if current_screen != null:
		current_screen.queue_free()
		data.set_former_screen(screen-1)

	current_screen = screen_factory.get_fresh_screen(screen)
	current_screen.setup(self, data)
	current_screen.screen_transition_requested.connect(switch_screen.bind())
	current_screen.name = "ScreenMachine"
	call_deferred("add_child", current_screen)
