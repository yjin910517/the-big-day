extends Node2D


signal game_over(reason)


@onready var bubble_control = $ConversationController
@onready var camera_control = $CameraController
@onready var anxiety_control = $AnxietyControl
@onready var wine_control = $WineControl
@onready var bathroom_control = $BathroomControl
@onready var bathroom = $Bathroom
@onready var status_display = $StatusDisplay


var current_level
var level_data = [
	# level 0
	{"camera": {
		"spawn_interval": 5,
		"pos_list": [Vector2(160, 210), Vector2(600, 300), Vector2(600, 210)]
		},
	"bubble": {
		"spawn_interval": 2,
		"urgency_options": [false, false, true],
		"countdown_lower": 6,
		"countdown_upper": 10
		}, 
	}
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bubble_control.connect("update_anxiety", Callable(anxiety_control, "_on_bubble_cnt_update"))
	bubble_control.connect("update_bubble_cleared", Callable(self, "_on_update_bubble_cleared"))
	camera_control.connect("update_photo_taken", Callable(self, "_on_update_photo_taken"))
	
	wine_control.connect("wine_ingested", Callable(anxiety_control, "_on_wine_ingestion"))
	wine_control.connect("wine_ingested", Callable(bathroom_control, "_on_wine_ingestion"))
	bathroom_control.connect("bathroom_break", Callable(self, "_on_bathroom_break_start"))
	bathroom.connect("bathroom_completed", Callable(self, "_on_bathroom_break_completed"))
	
	# Game over signals
	anxiety_control.connect("game_over", Callable(self, "_on_game_over"))
	bathroom_control.connect("game_over", Callable(self, "_on_game_over"))
	camera_control.connect("game_over", Callable(self, "_on_game_over"))
	bubble_control.connect("game_over", Callable(self, "_on_game_over"))
	wine_control.connect("game_over", Callable(self, "_on_game_over"))
	
	bathroom.position = Vector2(0, 0)
	camera_control.position = Vector2(0, 0)
	bubble_control.position = Vector2(0, 0)
	

func start_game():
		
	bathroom.hide()
	
	# to do: reset game clock
	# to do: reset labels
	
	anxiety_control.start_game()
	wine_control.start_game()
	bathroom_control.reset()
	
	current_level = 0
	var camera_params = level_data[current_level]["camera"]
	camera_control.update_level_params(camera_params)
	var bubble_params = level_data[current_level]["bubble"]
	bubble_control.update_level_params(bubble_params)
	
	# to do: run level timer
	# update level data on all nodes when timer timeout
	
	bubble_control.start_game()
	camera_control.start_game()


func _on_update_bubble_cleared(num_bubbles):
	status_display.set_bubble_count(num_bubbles)


func _on_update_photo_taken(num_bubbles):
	status_display.set_photo_count(num_bubbles)
	

# triggered by bathroom control button click
func _on_bathroom_break_start():
	bathroom.take_break()
	anxiety_control.start_bathroom_break()
	camera_control.pause_camera()
	bubble_control.pause_convo()
	
	remove_child(anxiety_control)
	bathroom.add_child(anxiety_control)


# triggered by bathroom signal
func _on_bathroom_break_completed():
	bathroom_control.reset()
	anxiety_control.return_from_break()
	camera_control.resume_camera()
	bubble_control.resume_convo()
	
	bathroom.remove_child(anxiety_control)
	add_child(anxiety_control)
	

# show game over GUD
func _on_game_over(failed_reason):
	# pause everything
	anxiety_control.end_game()
	bathroom_control.end_game()
	camera_control.end_game()
	bubble_control.end_game()
	
	emit_signal("game_over", failed_reason)
