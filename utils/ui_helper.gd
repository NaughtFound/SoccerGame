class_name UIHelper

static var flags_texture: Dictionary[String, Texture2D] = {}

static func get_ui_score_text(scores: Dictionary[Team.TeamSide, int]) -> String:
	return "%d - %d" % [scores[Team.TeamSide.Home], scores[Team.TeamSide.Away]]

static func get_ui_flag_texture(country: String) -> Texture2D:
	if not flags_texture.has(country):
		var flag := load("res://assets/art/ui/flags/flag-%s.png" % [country.to_lower()])
		flags_texture.set(country, flag)
	
	return flags_texture[country]

static func get_ui_time_text(time_left: float) -> String:
	if time_left < 0:
		return "OVERTIME!"
	
	var minutes := int(time_left/60)
	var seconds := int(time_left)%60
	
	return "%02d : %02d" % [minutes, seconds]
	
static func get_ui_scorer_text(player: Player) -> String:
	return "%s JUST SCORED!" % [player.full_name]

static func get_ui_score_info_text(
	countries: Dictionary[Team.TeamSide, String],
	scores: Dictionary[Team.TeamSide, int]
) -> String:
	var home_score := scores[Team.TeamSide.Home]
	var away_score := scores[Team.TeamSide.Away]
	if home_score == away_score:
		return "TEAMS ARE TIED %s" % [get_ui_score_text(scores)]
	if home_score > away_score:
		return "%s LEADS %s" % [countries[Team.TeamSide.Home], get_ui_score_text(scores)]
	
	return "%s LEADS %s" % [countries[Team.TeamSide.Away], get_ui_score_text(scores)]

static func get_ui_final_score_info_text(
	countries: Dictionary[Team.TeamSide, String],
	scores: Dictionary[Team.TeamSide, int]
) -> String:
	var home_score := scores[Team.TeamSide.Home]
	var away_score := scores[Team.TeamSide.Away]
	if home_score == away_score:
		return "TEAMS ARE TIED %s" % [get_ui_score_text(scores)]
	if home_score > away_score:
		return "%s WINS %s" % [countries[Team.TeamSide.Home], get_ui_score_text(scores)]
	
	return "%s WINS %s" % [countries[Team.TeamSide.Away], get_ui_score_text(scores)]
