class_name FormationStyle
extends Control

@onready var formation_text: Label = %Label

const LABELS: Dictionary[TeamFormation.Style, String] = {
	TeamFormation.Style.F_2_2_1: "2-2-1",
	TeamFormation.Style.F_2_1_2: "2-1-2",
	TeamFormation.Style.F_3_1_1: "3-1-1",
}

var current_stlye: TeamFormation.Style

func _ready() -> void:
	formation_text.text = LABELS[current_stlye]

func setup(style: TeamFormation.Style) -> void:
	current_stlye = style
