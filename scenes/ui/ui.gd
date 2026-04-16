class_name UI
extends CanvasLayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player_label: Label = %PlayerLabel
@onready var home_flag_texture: TextureRect = %HomeFlagTexture
@onready var score_label: Label = %ScoreLabel
@onready var away_flag_texture: TextureRect = %AwayFlagTexture
@onready var time_label: Label = %TimeLabel
@onready var goal_scorer_label: Label = %GoalScorerLabel
@onready var score_info_label: Label = %ScoreInfoLabel

var last_ball_carrier: Player

func _init() -> void:
	GameEvents.ball_carried.connect(on_ball_carried.bind())
	GameEvents.ball_released.connect(on_ball_released.bind())
	GameEvents.score_updated.connect(on_score_updated.bind())
	GameEvents.team_reset.connect(on_team_reset.bind())
	GameEvents.game_over.connect(on_game_over.bind())

func _ready() -> void:
	update_scores()
	update_flags()
	update_time()
	
	player_label.text = ""
	last_ball_carrier = null

func _process(_delta: float) -> void:
	update_time()
	
func update_scores() -> void:
	score_label.text = UIHelper.get_ui_score_text(GameManager.scores)
	
func update_flags() -> void:
	var home_country := GameManager.countries[Team.TeamSide.Home]
	var away_country := GameManager.countries[Team.TeamSide.Away]
	
	home_flag_texture.texture = UIHelper.get_ui_flag_texture(home_country)
	away_flag_texture.texture = UIHelper.get_ui_flag_texture(away_country)

func update_time() -> void:
	time_label.text = UIHelper.get_ui_time_text(GameManager.time_left)

func on_ball_carried(_player: Player) -> void:
	player_label.text = _player.full_name
	last_ball_carrier = _player
	
func on_ball_released() -> void:
	player_label.text = ""

func on_score_updated() -> void:
	update_scores()
	if last_ball_carrier != null:
		goal_scorer_label.text = UIHelper.get_ui_scorer_text(last_ball_carrier)
	score_info_label.text = UIHelper.get_ui_score_info_text(
		GameManager.countries,
		GameManager.scores
	)
	animation_player.play("GoalAppear")
	
func on_team_reset() -> void:
	if last_ball_carrier != null:
		animation_player.play("GoalHide")

func on_game_over() -> void:
	score_info_label.text = UIHelper.get_ui_final_score_info_text(
		GameManager.countries,
		GameManager.scores
	)
	animation_player.play("GameOver")
