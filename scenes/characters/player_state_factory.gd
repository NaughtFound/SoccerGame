class_name PlayerStateFactory

var states: Dictionary

func _init() -> void:
	states = {
		Player.State.MOVING: PlayerStateMoving,
		Player.State.TACKLING: PlayerStateTackling,
		Player.State.RECOVERING: PlayerStateRecovering,
		Player.State.PREPKICK: PlayerStatePrepKick,
		Player.State.KICK: PlayerStateKick,
		Player.State.PASS: PlayerStatePass,
		Player.State.BICYCLEKICK: PlayerStateBicycleKick,
		Player.State.VOLLEYKICK: PlayerStateVolleyKick,
		Player.State.HEADER: PlayerStateHeader,
		Player.State.CHESTCONTROL: PlayerStateChestControl,
		Player.State.HURT: PlayerStateHurt,
		Player.State.DIVE: PlayerStateDive,
		Player.State.CELEBRATNG: PlayerStateCelebrate,
		Player.State.MOURNING: PlayerStateMourn,
		Player.State.RESETING: PlayerStateReset,
	}

func get_fresh_state(state: Player.State) -> PlayerState:
	assert(states.has(state), "State doesn't exists!")
	return states[state].new()
