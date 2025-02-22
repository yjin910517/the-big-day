extends Node2D


signal intro_completed()

@onready var click_detect = $NextButton/ClickDetect
@onready var p0 = $Page0
@onready var p1 = $Page1
@onready var p2 = $Page2
@onready var page_array = [p0, p1, p2]

var current_page_idx
var current_page


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	click_detect.connect("gui_input", Callable(self, "_on_button_gui_input"))
	for p in page_array:
		p.hide()
		p.position = Vector2(0, 0)
	
	current_page_idx = 0
	current_page = page_array[current_page_idx]
	current_page.show()
	

func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		current_page_idx +=1
		if current_page_idx == len(page_array):
			emit_signal("intro_completed")
		else:
			current_page.hide()
			current_page = page_array[current_page_idx]
			current_page.show()
