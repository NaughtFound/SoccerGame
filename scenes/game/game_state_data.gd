class_name GameStateData

var scored_side: Team.TeamSide

static func build() -> GameStateData:
	return GameStateData.new()

func set_scored_side(side: Team.TeamSide) -> GameStateData:
	scored_side = side
	return self
