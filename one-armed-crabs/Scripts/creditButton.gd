extends Button
@onready var credit_label: PanelContainer = $"../creditLabel"

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_pressed() -> void: #opens 
	credit_label.visible = !credit_label.visible
