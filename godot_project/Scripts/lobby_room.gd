extends Node2D

@onready var bubble_control = $ConversationController
@onready var camera_control = $CameraController
@onready var anxiety_control = $AnxietyControl
@onready var wine_control = $WineControl


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bubble_control.connect("update_anxiety", Callable(anxiety_control, "_on_bubble_cnt_update"))
	
	camera_control.position = Vector2(0, 0)
	bubble_control.position = Vector2(0, 0)
	
