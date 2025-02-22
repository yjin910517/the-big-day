extends Node2D


signal bathroom_break()
signal game_over(failed_reason)


@onready var bathroom_button = $BathroomButton
@onready var countdown = $CountdownDisplay
@onready var click_detect = $BathroomButton/ClickDetect
@onready var progress = $BathroonBar

var bladder_capacity = 10
var fill_velocity = 0.3
var current_fill
var is_reacting


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	click_detect.connect("gui_input", Callable(self, "_on_button_gui_input"))
	countdown.connect("bladder_exploded", Callable(self, "_on_bladder_exploded"))
	
	progress.max_value = bladder_capacity
	progress.step = 0.1


func reset():
	# freeze button click
	bathroom_button.frame = 0
	click_detect.hide()
	
	# activate bar progress
	current_fill = 0
	progress.value = current_fill
	is_reacting = true
	progress.set_process(true)
	

func end_game():
	is_reacting = false
	progress.set_process(false)
	countdown.reset_countdown()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_reacting:
		current_fill += delta * fill_velocity
		_update_bar_progress()


# update bar display 
func _update_bar_progress():
	if current_fill >= bladder_capacity:
		# freeze full bar
		progress.value = bladder_capacity
		is_reacting = false
		progress.set_process(false)
		# activate button
		bathroom_button.frame = 1
		click_detect.show()
		countdown.initiate_countdown()
	else:
		progress.value = current_fill


# detect bathroom button click
func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		countdown.reset_countdown()
		emit_signal("bathroom_break")


# connected to wine controller signal by main
func _on_wine_ingestion():
	current_fill += 3 # wine accelerates bathroom
	_update_bar_progress()


# detect bathroom countdown timeout
func _on_bladder_exploded():
	emit_signal("game_over", "bathroom_emergency")
