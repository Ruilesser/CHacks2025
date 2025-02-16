extends Control

@export var dest_scene :PackedScene
@onready var cam2d = $Camera2D

func _ready() -> void:
	$Panel/MarginContainer/VBoxContainer/StartButton.grab_focus()
	$OptionsMenu.visible = false
	$creditLabel.visible = false
	$Music.play()
	pass
	
	
func _on_start_button_pressed() -> void:
	play_sound($Select_SFX)
	print("level 1 start")
	get_tree().change_scene_to_packed(dest_scene) #go to level 1 scene
	cam_move(cam2d, "position", Vector2(0,-300), 4.0)
	
func _on_options_pressed() -> void:
	play_sound($Select_SFX)
	print("Options")
	$Panel/MarginContainer.visible = false
	$OptionsMenu.visible = true
	$OptionsMenu/Back_Button.grab_focus()
	

func _on_credits_pressed() -> void:
	play_sound($Select_SFX)
	$Panel/MarginContainer/VBoxContainer.visible = false
	$creditLabel.visible = true
	$creditLabel/Back.grab_focus()

func _on_quit_pressed() -> void:
	play_sound($Select_SFX)
	get_tree().quit()

func _on_options_menu_is_menu() -> void:
	play_sound($Select_SFX)
	$Panel/MarginContainer.visible = true
	$Panel/MarginContainer/VBoxContainer/StartButton.grab_focus()

func _on_back_pressed() -> void:
	play_sound($Select_SFX)
	$Panel/MarginContainer/VBoxContainer.visible = true
	$creditLabel.visible = false
	$Panel/MarginContainer/VBoxContainer/StartButton.grab_focus()
	

	
func cam_move(node, property, fin_val, duration):
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, property, fin_val, duration)

func play_sound(sfx: AudioStreamPlayer):
	randomize()
	sfx.pitch_scale = randf_range(0.8, 1.2)
	sfx.play()

func _on_start_button_mouse_entered() -> void:
	play_sound($Hover_SFX)


func _on_options_mouse_entered() -> void:
	play_sound($Hover_SFX)


func _on_credits_mouse_entered() -> void:
	play_sound($Hover_SFX)


func _on_quit_mouse_entered() -> void:
	play_sound($Hover_SFX)
