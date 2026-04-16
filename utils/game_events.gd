extends Node2D

signal team_scored(_team: Team)
signal team_reset()
signal team_kickoff_ready(_team: Team)
signal kickoff_started()
signal ball_carried(_player: Player)
signal ball_released()
signal score_updated()
signal game_over()
signal impact_received(_position: Vector2, is_high: bool)
