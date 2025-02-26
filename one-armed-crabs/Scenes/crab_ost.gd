extends AudioStreamPlayer

const game_music = preload("res://Assets/Music and SFX/crab_game_ost_O.ogg")

func play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	play_music(game_music)
