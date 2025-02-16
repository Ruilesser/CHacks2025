extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$OptionsMenu.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause_or_unpause()

func pause_or_unpause():
	if get_tree().paused == true:
		$OptionsMenu.visible = false
		get_tree().paused = false
	elif get_tree().paused == false:
		$OptionsMenu.visible = true
		$OptionsMenu/Back_Button.grab_focus()
		get_tree().paused = true
