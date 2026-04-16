class_name GameStateGameOver
extends GameState

func _enter_tree() -> void:
	GameEvents.game_over.emit()
