extends Area2D



func _on_body_entered(body: Node2D) -> void:# Replac
	if body.get_name() == "Ball":
		print(body.get_name())
	
	pass 
	
