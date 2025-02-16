extends Camera2D
#
#var targ_pos: Vector2
#var pos: Vector2
#var pan_speed: float = 0.1
#var is_pan: bool = true
## Called when the node enters the scene tree for the first time.
#
#func _ready() -> void:
	#pos = Vector2(0, -300)
	#targ_pos = pos + Vector2(0, 0)
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if is_pan:
		#pos = pos.lerp(targ_pos, pan_speed)
		#
		#if pos.distance_to(targ_pos) < 1.0:
			#is_pan = false
