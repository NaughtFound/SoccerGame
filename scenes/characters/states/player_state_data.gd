class_name PlayerStateData

var hurt_direction: Vector2
var kick_direction: Vector2
var kick_power: float
var reset_position: Vector2

static func build() -> PlayerStateData:
	return PlayerStateData.new()

func set_hurt_direction(direction: Vector2) -> PlayerStateData:
	hurt_direction = direction
	return self

func set_kick_direction(direction: Vector2) -> PlayerStateData:
	kick_direction = direction
	return self

func set_kick_power(power: float) -> PlayerStateData:
	kick_power = power
	return self

func set_reset_position(position: Vector2) -> PlayerStateData:
	reset_position = position
	return self
