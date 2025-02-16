extends Node2D


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area:
		pass 

# another signal function cuz idk which one will recognize the claw
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_name() == "Claw":
		print(body.get_name())
		pass # Replace with function body.
