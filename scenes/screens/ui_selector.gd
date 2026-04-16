class_name UISelector
extends Control

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var p1_selected: TextureRect = %"1P"
@onready var p2_selected: TextureRect = %"2P"
@onready var cpu_selected: TextureRect = %CPU

signal selected(control_scheme: Player.ControlScheme)

var control_scheme: Player.ControlScheme
var is_selected: bool
var is_enabled: bool

func _init() -> void:
	is_selected = false
	is_enabled = true
	
func setup(_control_scheme: Player.ControlScheme) -> void:
	control_scheme = _control_scheme

func _ready() -> void:
	p1_selected.visible = control_scheme == Player.ControlScheme.P1
	p2_selected.visible = control_scheme == Player.ControlScheme.P2
	cpu_selected.visible = control_scheme == Player.ControlScheme.CPU

func _process(_delta: float) -> void:
	if not is_enabled:
		return
	if not is_selected and KeyUtils.is_action_just_pressed(control_scheme, KeyUtils.Action.SHOOT):
		is_selected = true
		animation_player.play("Selected")
		SoundPlayer.play(SoundPlayer.Sound.UI_SELECT)
		selected.emit(control_scheme)
	if is_selected and KeyUtils.is_action_just_pressed(control_scheme, KeyUtils.Action.PASS):
		is_selected = false
		animation_player.play("Selecting")

func disable() -> void:
	visible = false
	is_enabled = false

func enable() -> void:
	visible = true
	is_enabled = true
