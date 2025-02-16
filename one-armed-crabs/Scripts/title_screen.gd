extends Control

@export var dest_scene :PackedScene
@onready var cam2d = $Camera2D

func _ready() -> void:
	$Panel/MarginContainer/VBoxContainer/StartButton.grab_focus()
	$OptionsMenu.visible = false
	$creditLabel.visible = false
	pass
	
	
func _on_start_button_pressed() -> void:
	print("level 1 start")
	get_tree().change_scene_to_packed(dest_scene) #go to level 1 scene
	cam_move(cam2d, "position", Vector2(0,-300), 4.0)
	
func _on_options_pressed() -> void:
	print("Options")
	$Panel/MarginContainer.visible = false
	$OptionsMenu.visible = true
	$OptionsMenu/Back_Button.grab_focus()
	

func _on_credits_pressed() -> void:
	$Panel/MarginContainer/VBoxContainer.visible = false
	$creditLabel.visible = true
	$creditLabel/Back.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_options_menu_is_menu() -> void:
	$Panel/MarginContainer.visible = true
	$Panel/MarginContainer/VBoxContainer/StartButton.grab_focus()

func _on_back_pressed() -> void:
	$Panel/MarginContainer/VBoxContainer.visible = true
	$creditLabel.visible = false
	$Panel/MarginContainer/VBoxContainer/StartButton.grab_focus()
	
func cam_move(node, property, fin_val, duration):
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, property, fin_val, duration)
