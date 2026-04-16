class_name PlayerStateMoving
extends PlayerState

func _process(_delta: float) -> void:
	if player.control_scheme == player.ControlScheme.CPU:
		agent.make_decisions()
	else:
		handle_human_movement()
	player.set_movement_animation()

func handle_human_movement() -> void:
	var direction := KeyUtils.get_input_vector(player.control_scheme)
	player.velocity = direction * player.speed
	
	if KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.SHOOT):
		if player.has_ball():
			state_transition(Player.State.PREPKICK)
		elif ball.can_air_interact():
			if player.velocity == Vector2.ZERO:
				var heading_value := player.heading.dot(ball.velocity.normalized())
				if heading_value >= 0:
					state_transition(Player.State.VOLLEYKICK)
				else:
					state_transition(Player.State.BICYCLEKICK)
			else:
				state_transition(Player.State.HEADER)
		elif player.velocity != Vector2.ZERO:
			state_transition(Player.State.TACKLING)
			
	elif KeyUtils.is_action_just_pressed(player.control_scheme, KeyUtils.Action.PASS):
		if player.has_ball():
			state_transition(Player.State.PASS)
