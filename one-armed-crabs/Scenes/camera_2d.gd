extends Camera2D

var targ_pos: Vector2 = Vector2(0, 0)
var trans_speed: float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.lerp(targ_pos, trans_speed)
