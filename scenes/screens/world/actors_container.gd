class_name ActorsContainer
extends Node2D

const SPARK_PREFAB := preload("res://scenes/spark/spark.tscn")

func _init() -> void:
	GameEvents.impact_received.connect(on_impact_received.bind())
	
func on_impact_received(_position: Vector2, _high_impact: bool = false) -> void:
	var spark := SPARK_PREFAB.instantiate()
	spark.position = _position
	call_deferred("add_child", spark)
