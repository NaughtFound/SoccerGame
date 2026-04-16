class_name TeamFormation

enum Style {
	F_2_2_1,
	F_2_1_2,
	F_3_1_1
}

enum Mode {PreStart, PostStart}

const FORMATIONS: Dictionary = {
 	Style.F_2_2_1: {
		Player.Role.GK: [
			{
				Mode.PreStart: Vector2(75.0, 180.0),
				Mode.PostStart: Vector2(75.0, 180.0)
			}
		],
		Player.Role.CB: [
			{
				Mode.PreStart: Vector2(180.0, 120.0),
				Mode.PostStart: Vector2(180.0, 120.0)
			},
			{
				Mode.PreStart: Vector2(180.0, 240.0),
				Mode.PostStart: Vector2(180.0, 240.0)
			}
		],
		Player.Role.LB: [
			{
				Mode.PreStart: Vector2(180.0, 85.0),
				Mode.PostStart: Vector2(180.0, 85.0)
			}
		],
		Player.Role.RB: [
			{
				Mode.PreStart: Vector2(180.0, 275.0),
				Mode.PostStart: Vector2(180.0, 275.0)
			}
		],
		Player.Role.CM: [
			{
				Mode.PreStart: Vector2(280.0, 120.0),
				Mode.PostStart: Vector2(280.0, 120.0)
			},
			{
				Mode.PreStart: Vector2(280.0, 240.0),
				Mode.PostStart: Vector2(280.0, 240.0)
			}
		],
		Player.Role.LW: [
			{
				Mode.PreStart: Vector2(400.0, 75.0),
				Mode.PostStart: Vector2(565.0, 75.0)
			}
		],
		Player.Role.RW: [
			{
				Mode.PreStart: Vector2(400.0, 285.0),
				Mode.PostStart: Vector2(565.0, 285.0)
			}
		],
		Player.Role.ST: [
			{
				Mode.PreStart: Vector2(400.0, 130.0),
				Mode.PostStart: Vector2(640.0, 180.0)
			}
		],
	},
	Style.F_2_1_2: {
		Player.Role.GK: [
			{
				Mode.PreStart: Vector2(75.0, 180.0),
				Mode.PostStart: Vector2(75.0, 180.0)
			}
		],
		Player.Role.CB: [
			{
				Mode.PreStart: Vector2(180.0, 120.0),
				Mode.PostStart: Vector2(180.0, 120.0)
			},
			{
				Mode.PreStart: Vector2(180.0, 240.0),
				Mode.PostStart: Vector2(180.0, 240.0)
			}
		],
		Player.Role.LB: [
			{
				Mode.PreStart: Vector2(180.0, 85.0),
				Mode.PostStart: Vector2(180.0, 85.0)
			}
		],
		Player.Role.RB: [
			{
				Mode.PreStart: Vector2(180.0, 275.0),
				Mode.PostStart: Vector2(180.0, 275.0)
			}
		],
		Player.Role.CM: [
			{
				Mode.PreStart: Vector2(280.0, 180.0),
				Mode.PostStart: Vector2(280.0, 180.0)
			}
		],
		Player.Role.LW: [
			{
				Mode.PreStart: Vector2(400.0, 75.0),
				Mode.PostStart: Vector2(565.0, 75.0)
			}
		],
		Player.Role.RW: [
			{
				Mode.PreStart: Vector2(400.0, 285.0),
				Mode.PostStart: Vector2(565.0, 285.0)
			}
		],
		Player.Role.ST: [
			{
				Mode.PreStart: Vector2(400.0, 145.0),
				Mode.PostStart: Vector2(640.0, 150.0)
			},
			{
				Mode.PreStart: Vector2(400.0, 215.0),
				Mode.PostStart: Vector2(640.0, 210.0)
			}
		],
	},
	Style.F_3_1_1: {
		Player.Role.GK: [
			{
				Mode.PreStart: Vector2(75.0, 180.0),
				Mode.PostStart: Vector2(75.0, 180.0)
			}
		],
		Player.Role.CB: [
			{
				Mode.PreStart: Vector2(180.0, 180.0),
				Mode.PostStart: Vector2(180.0, 180.0)
			},
			{
				Mode.PreStart: Vector2(180.0, 130.0),
				Mode.PostStart: Vector2(180.0, 130.0)
			},
			{
				Mode.PreStart: Vector2(180.0, 230.0),
				Mode.PostStart: Vector2(180.0, 230.0)
			}
		],
		Player.Role.LB: [
			{
				Mode.PreStart: Vector2(180.0, 85.0),
				Mode.PostStart: Vector2(180.0, 85.0)
			}
		],
		Player.Role.RB: [
			{
				Mode.PreStart: Vector2(180.0, 275.0),
				Mode.PostStart: Vector2(180.0, 275.0)
			}
		],
		Player.Role.CM: [
			{
				Mode.PreStart: Vector2(280.0, 180.0),
				Mode.PostStart: Vector2(280.0, 180.0)
			}
		],
		Player.Role.LW: [
			{
				Mode.PreStart: Vector2(400.0, 145.0),
				Mode.PostStart: Vector2(640.0, 150.0)
			}
		],
		Player.Role.RW: [
			{
				Mode.PreStart: Vector2(400.0, 215.0),
				Mode.PostStart: Vector2(640.0, 210.0)
			}
		],
		Player.Role.ST: [
			{
				Mode.PreStart: Vector2(400.0, 130.0),
				Mode.PostStart: Vector2(640.0, 180.0)
			}
		],
	},
}

const KICKOFF := [Vector2(410.0, 160.0), Vector2(425.0, 195.0)]

static func get_formation_positions(style: Style, players: Array[PlayerResource]) -> Array[Dictionary]:
	var positions: Array[Dictionary] = []
	var role_idx := {}
	var formations := FORMATIONS[style] as Dictionary
	
	for player in players:
		var role_index := 0
		assert(formations.has(player.role))
		var arr: Array = formations[player.role]
		if role_idx.has(player.role):
			role_idx[player.role]+=1
			role_idx[player.role]%=arr.size()
			role_index = role_idx[player.role]
		else:
			role_idx.set(player.role, 0)
		
		positions.append(arr[role_index])
	return positions
