extends Control

signal is_menu


func _on_back_button_pressed() -> void:
		emit_signal("is_menu")
		$".".visible = false
		if get_tree():
			get_tree().paused = false

func _input(event) -> void:
	if(event.is_action_pressed("ui_cancel") && get_tree().current_scene.name == "title_screen"):
		emit_signal("is_menu")
		$".".visible = false


func _on_quit_pressed() -> void:
	if get_tree():
			get_tree().paused = false
	if (get_tree().current_scene.name == "TitleScreen"):
		get_tree().quit()
	else:
		get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
