extends Node2D


@onready var bubble = $Bubble
@onready var movement = $AnimationPlayer
@onready var click_detect = $Bubble/ClickDetect
@onready var audio = $ClearSound


@export var reacting_demo: bool


func _ready() -> void:
	click_detect.connect("gui_input", Callable(self, "_on_bubble_gui_input"))
	
	if reacting_demo:
		movement.play("bubble_dynamic")


# for click interaction
func _on_bubble_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if reacting_demo:
			audio.play()
			hide()
