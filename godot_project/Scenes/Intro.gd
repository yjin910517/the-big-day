extends Node2D


signal intro_completed()

@onready var click_detect = $NextButton/ClickDetect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	click_detect.connect("gui_input", Callable(self, "_on_button_gui_input"))


func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("intro_completed")
