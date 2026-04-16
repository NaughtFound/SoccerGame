class_name FormationSelectionScreen
extends Screen

const ITEMS_PER_ROW := 3.0
const ANCHOR_POINT := Vector2(35, 80)
const FLAG_SIZE := Vector2(22, 14)*2
const PADDING := Vector2(0, 20)
const UI_SELECTOR_PREFAB := preload("res://scenes/screens/ui_selector.tscn")
const FORMATION_STYLE_PREFAB := preload("res://scenes/screens/formation_selection/formation_style.tscn")

const SIDES := {
	Player.ControlScheme.P1: Team.TeamSide.Home,
	Player.ControlScheme.P2: Team.TeamSide.Away,
	Player.ControlScheme.CPU: Team.TeamSide.Away,
}

@onready var formations_container: Control = %FormationsContainer

var selection: Dictionary[Player.ControlScheme, Vector2]
var selector: Dictionary[Player.ControlScheme, UISelector]

func _init() -> void:
	selection = {
		Player.ControlScheme.P1: Vector2.ZERO,
		Player.ControlScheme.P2: Vector2.ZERO,
		Player.ControlScheme.CPU: Vector2.ZERO,
	}
	selector = {}

func _ready() -> void:
	place_formations()
	place_selectors()
	
func _process(_delta: float) -> void:
	for s: UISelector in selector.values():
		if s.is_selected or not s.is_enabled:
			continue
		if KeyUtils.is_action_just_pressed(s.control_scheme, KeyUtils.Action.RIGHT):
			try_navigate(s, Vector2.RIGHT)
		elif KeyUtils.is_action_just_pressed(s.control_scheme, KeyUtils.Action.LEFT):
			try_navigate(s, Vector2.LEFT)
		elif KeyUtils.is_action_just_pressed(s.control_scheme, KeyUtils.Action.UP):
			try_navigate(s, Vector2.UP)
		elif KeyUtils.is_action_just_pressed(s.control_scheme, KeyUtils.Action.DOWN):
			try_navigate(s, Vector2.DOWN)
		elif KeyUtils.is_action_just_pressed(s.control_scheme, KeyUtils.Action.PASS):
			go_back()
			
func vec2_to_idx(vec2: Vector2i) -> int:
	return vec2.x+vec2.y*int(ITEMS_PER_ROW)
			
func try_navigate(ui_selector: UISelector, direction: Vector2):
	var nb_rows := roundi(TeamFormation.Style.size()/ITEMS_PER_ROW)
	var rect := Rect2i(0, 0, int(ITEMS_PER_ROW), nb_rows)
	var new_pos := selection[ui_selector.control_scheme]+direction
	
	if rect.has_point(new_pos) and vec2_to_idx(new_pos) < TeamFormation.Style.size():
		selection[ui_selector.control_scheme]+= direction
		var flag_idx := vec2_to_idx(selection[ui_selector.control_scheme])
		ui_selector.position = formations_container.get_child(flag_idx).position
		SoundPlayer.play(SoundPlayer.Sound.UI_NAV)

func place_formations() -> void:
	var nb_rows := roundi(TeamFormation.Style.size()/ITEMS_PER_ROW)
	var space_size := (
		formations_container.size -
		FLAG_SIZE*Vector2(ITEMS_PER_ROW, nb_rows) -
		ANCHOR_POINT*Vector2(2, 1)-
		PADDING
	)
	var padding := space_size/Vector2(ITEMS_PER_ROW-1, nb_rows-1)
	if nb_rows == 1:
		padding.y = 0.0
	
	
	for i in range(TeamFormation.Style.size()):
		var style: TeamFormation.Style = TeamFormation.Style.values()[i]
		var formaiton_style: FormationStyle = FORMATION_STYLE_PREFAB.instantiate()
		formaiton_style.setup(style)
		formaiton_style.name = str(style)
		var idx := Vector2(i%int(ITEMS_PER_ROW), int(i/ITEMS_PER_ROW))
		formaiton_style.position = ANCHOR_POINT+(FLAG_SIZE+padding)*idx
		formaiton_style.z_index = 1
		formations_container.add_child(formaiton_style)

func place_selectors() -> void:
	for control_scheme in GameManager.control_schemes.values():
		place_selector(control_scheme)
	
	if GameManager.control_schemes.values().has(Player.ControlScheme.CPU):
		selector[Player.ControlScheme.CPU].disable()
	
func place_selector(control_scheme: Player.ControlScheme) -> void:
	var ui_selector: UISelector = UI_SELECTOR_PREFAB.instantiate()
	ui_selector.setup(control_scheme)
	var idx := vec2_to_idx(selection[control_scheme])
	ui_selector.position = formations_container.get_child(idx).position
	ui_selector.selected.connect(on_selected.bind())
	selector[control_scheme] = ui_selector
	call_deferred("add_child", ui_selector)

func on_selected(control_scheme: Player.ControlScheme) -> void:
	var idx := vec2_to_idx(selection[control_scheme])
	GameManager.formations[SIDES[control_scheme]] = TeamFormation.Style.values()[idx]
	
	if selector.has(Player.ControlScheme.CPU):
		selector[Player.ControlScheme.CPU].call_deferred("enable")
	
	for s: UISelector in selector.values():
		if not s.is_selected:
			return
	
	screen_transition(SoccerGame.ScreenType.IN_GAME)
