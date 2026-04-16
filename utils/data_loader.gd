extends Node

var squads: Dictionary[String, Array]
var countries : Array[String]
var formations: Dictionary[String, TeamFormation.Style]

func _init() -> void:
	var file := FileAccess.open("res://assets/json/squads.json", FileAccess.READ)
	assert(file != null)
	var content := file.get_as_text()
	var json = JSON.new()
	var err := json.parse(content)
	assert(err == OK)
	
	for team in json.data:
		var country := team["country"] as String
		var players := team["players"] as Array
		squads.set(country, [])
		formations.set(country, team["formation"] as TeamFormation.Style)
		countries.append(country)
		assert(players.size() == 6)
		for player in players:
			var full_name := player["name"] as String
			var skin := player["skin"] as Player.SkinColor
			var role := player["role"] as Player.Role
			var speed := player["speed"] as float
			var power := player["power"] as float
			
			squads[country].append(PlayerResource.new(
				country,
				full_name,
				skin,
				role,
				speed,
				power
			))
	file.close()

func get_squad(country: String) -> Array[PlayerResource]:
	var players: Array[PlayerResource] = []
	for player in squads.get(country, []):
		players.append(player as PlayerResource)
	return players

func get_default_formation(country: String) -> TeamFormation.Style:
	return formations.get(country)
