class_name WorldScreen
extends Screen

const GAMEOVER_DURATION := 6000

var time_since_game_over: int
var is_gameover: bool


func _ready() -> void:
	is_gameover = false
	GameEvents.game_over.connect(on_game_over.bind())
	GameManager.reset()

func _process(_delta: float) -> void:
	if is_gameover and Time.get_ticks_msec() - time_since_game_over > GAMEOVER_DURATION:
		screen_transition(SoccerGame.ScreenType.MAIN_MENU)

func on_game_over() -> void:
	is_gameover = true
	time_since_game_over = Time.get_ticks_msec()
