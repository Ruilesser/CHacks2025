extends Control

@export var dest_scene :PackedScene
@onready var cam2d = $Camera2D

func _ready() -> void:
	$MainScreen/StartButton.grab_focus()
	print("start")
	pass

func _on_pressed() -> void:
	print("level 1 start")
	# get_tree().change_scene_to_packed(dest_scene) #go to level 1 scene
	cam_move(cam2d, "position", Vector2(0,0), 4.0)
	
	
func cam_move(node, property, fin_val, duration):
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, property, fin_val, duration)
	
