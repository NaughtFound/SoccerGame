class_name PlayerActionGK
extends PlayerAction

const MAX_MOVE_DISTANCE := 75

func do() -> void:
	agent.do_kick()
	agent.do_pass()
	agent.do_tackle()
	do_dive()

func calc_steering_force() -> Vector2:
	var steering_force := Vector2.ZERO
	steering_force += calc_on_duty_steering_force()
	steering_force += agent.calc_carrier_steering_force()
	steering_force += agent.calc_formation_steering_force()
	
	return steering_force

func calc_on_duty_steering_force() -> Vector2:
	var distance := player.position.distance_to(ball.position)
	
	return agent.calc_on_duty_steering_force() if distance <= MAX_MOVE_DISTANCE else Vector2.ZERO

func do_dive() -> void:
	if player.has_ball() or agent.is_ball_carried_by_teammate():
		return
		
	var distance := player.position.distance_to(player.own_goal.position)
	
	if distance > MAX_MOVE_DISTANCE:
		return

	if not ball.can_air_interact():
		return

	if ball.is_headed_for_scoring_area():
		player.switch_state(Player.State.DIVE)
