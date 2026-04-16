class_name PlayerStatePass
extends PlayerState

func _enter_tree() -> void:
	animation_player.play("Kick")
	SoundPlayer.play(SoundPlayer.Sound.PASS)
	
func on_animation_complete() -> void:
	state_transition(Player.State.MOVING)
	pass_ball()

func pass_ball() -> void:
	if player.has_ball():
		var target := find_teammate_in_view()
		
		if target == null:
			var direction := player.heading
			ball.pass_to(ball.position+direction*player.speed)
		else:
			ball.pass_to(target.position+target.velocity)

func find_teammate_in_view() -> Player:
	var players := teammate_detection_area.get_overlapping_bodies()
	var teammates := players.filter(
		func(p: Player): return p!=player and p.team == player.team
	)
	
	teammates.sort_custom(
		func(p1: Player, p2: Player):
			var p1_distance := p1.position.distance_squared_to(player.position) 
			var p2_distance := p2.position.distance_squared_to(player.position) 
			return p1_distance < p2_distance
	)
	
	if teammates.size() > 0:
		return teammates[0]
		
	return null
