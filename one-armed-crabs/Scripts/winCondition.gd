extends Node2D

@export var dest_scene :PackedScene

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_name() == "Ball":
		get_tree().change_scene_to_packed(dest_scene) #go to level 1 scene
	
	pass 
