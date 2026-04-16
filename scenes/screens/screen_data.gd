class_name ScreenData

var former_screen: SoccerGame.ScreenType

static func build() -> ScreenData:
	return ScreenData.new()

func set_former_screen(screen: SoccerGame.ScreenType) -> ScreenData:
	former_screen = screen
	return self
