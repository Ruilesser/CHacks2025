extends TextureButton

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn") #go to level 1 scene
	print("level 1 start")
