extends Control

signal is_menu


func _on_back_button_pressed() -> void:
		emit_signal("is_menu")
		$".".visible = false

func _input(event) -> void:
	if(event.is_action_pressed("ui_cancel") && get_tree().current_scene.name == "title_screen"):
		emit_signal("is_menu")
		$".".visible = false
