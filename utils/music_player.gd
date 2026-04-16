extends Node

enum Music {
	NONE,
	GAMEPLAY,
	MENU,
	TOURNAMENT,
	WIN
}

const SFX_MAP: Dictionary[Music, AudioStream] = {
	Music.GAMEPLAY: preload("res://assets/music/gameplay.mp3"),
	Music.MENU: preload("res://assets/music/menu.mp3"),
	Music.TOURNAMENT: preload("res://assets/music/tournament.mp3"),
	Music.WIN: preload("res://assets/music/win.mp3"),
}

var stream_player: AudioStreamPlayer
var current_music: Music

func _init() -> void:
	current_music = Music.NONE
	stream_player = AudioStreamPlayer.new()
	call_deferred("add_child", stream_player)


func play(music: Music) -> void:
	if music == current_music:
		return
	if music == Music.NONE:
		stream_player.stop()
		stream_player.stream = null
	else:
		stream_player.stream = SFX_MAP[music]
		stream_player.play()
	current_music = music
