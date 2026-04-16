class_name MainMenuScreen
extends Screen

enum ControlMode {SinglePlayer, TwoPlayer}

const MENU_TEXTURES := {
	ControlMode.SinglePlayer: [
		preload("res://assets/art/ui/mainmenu/1-player.png"),
		preload("res://assets/art/ui/mainmenu/1-player-selected.png")
	],
	ControlMode.TwoPlayer: [
		preload("res://assets/art/ui/mainmenu/2-players.png"),
		preload("res://assets/art/ui/mainmenu/2-players-selected.png")
	],
}

@onready var selectable_menu_nodes: Dictionary[ControlMode, TextureRect] = {
	ControlMode.SinglePlayer: %SinglePlayer,
	ControlMode.TwoPlayer: %TwoPlayer
}
@onready var selection_icon: TextureRect = %SelectionIcon

var current_mode: ControlMode
var is_active: bool

func _init() -> void:
	is_active = false
	current_mode = ControlMode.SinglePlayer

func _process(_delta: float) -> void:
	if is_active:
		if KeyUtils.is_action_just_pressed(Player.ControlScheme.P1, KeyUtils.Action.UP):
			change_mode(ControlMode.SinglePlayer)
		elif KeyUtils.is_action_just_pressed(Player.ControlScheme.P1, KeyUtils.Action.DOWN):
			change_mode(ControlMode.TwoPlayer)
		elif KeyUtils.is_action_just_pressed(Player.ControlScheme.P1, KeyUtils.Action.SHOOT):
			submit_mode()

func change_mode(_mode: ControlMode) -> void:
	current_mode = _mode
	SoundPlayer.play(SoundPlayer.Sound.UI_NAV)
	for mode in selectable_menu_nodes:
		if _mode == mode:
			selectable_menu_nodes[mode].texture = MENU_TEXTURES[mode][1]
			selection_icon.position.y = selectable_menu_nodes[mode].position.y
		else:
			selectable_menu_nodes[mode].texture = MENU_TEXTURES[mode][0]

func submit_mode() -> void:
	SoundPlayer.play(SoundPlayer.Sound.UI_SELECT)
	
	if current_mode == ControlMode.SinglePlayer:
		GameManager.control_schemes = {
			Team.TeamSide.Home: Player.ControlScheme.P1,
			Team.TeamSide.Away: Player.ControlScheme.CPU,
		}
	elif current_mode == ControlMode.TwoPlayer:
		GameManager.control_schemes = {
			Team.TeamSide.Home: Player.ControlScheme.P1,
			Team.TeamSide.Away: Player.ControlScheme.P2,
		}
	screen_transition(SoccerGame.ScreenType.TEAM_SELECTION)

func on_set_active() -> void:
	is_active = true
