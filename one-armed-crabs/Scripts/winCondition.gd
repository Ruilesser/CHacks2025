extends Node2D

@export var dest_scene :PackedScene
@export var string_scene :String

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_name() == "Ball":
		print("Touching")
		call_deferred("change_scene")  # Defer the scene change

func change_scene() -> void:
	#get_tree().change_scene_to_packed(dest_scene)
	get_tree().change_scene_to_file(string_scene)
