extends Node

const TEST_MAIN_THEME : AudioStream = preload("res://Sound/Music/TestMainTheme.ogg")

func play(music: String):
	var audio: AudioStreamPlayer = $AudioStreamPlayer
	match music:
		"MainTheme":
			audio.stream = TEST_MAIN_THEME
		_:
			audio.stream = TEST_MAIN_THEME
	audio.play();


func stop():
	var audio: AudioStreamPlayer = $AudioStreamPlayer
	audio.stop();
