extends Control

@export var dest_scene :PackedScene


func _ready() -> void:
	$MainScreen/StartButton.grab_focus()
	print("start")
	pass

func _on_pressed() -> void:
	print("level 1 start")
	get_tree().change_scene_to_packed(dest_scene) #go to level 1 scene
	
