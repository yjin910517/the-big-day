extends Node2D

# handle both win and fail
signal game_over(final_dataset)


@onready var bubble_control = $ConversationController
@onready var camera_control = $CameraController
@onready var anxiety_control = $AnxietyControl
@onready var wine_control = $WineControl
@onready var bathroom_control = $BathroomControl
@onready var bathroom = $Bathroom
@onready var status_display = $StatusDisplay
@onready var level_timer = $LevelTimer
@onready var cooldown_timer = $CooldownTimer
@onready var tipsy = $TipsyVision


var num_bubbles_cleared
var num_photo_taken
var is_in_bathroom
var day_end
var is_over # use it to prevent repeat triggers of different fail reasons

var level_duration = 30
var current_level

# level parameters
var level_data = [
	# level 0
	{"camera": {
		"spawn_interval": 11,
		"pos_list": [Vector2(100, 250)]
		},
	"bubble": {
		"spawn_interval": 3,
		"urgency_options": [false],
		"countdown_lower": 6,
		"countdown_upper": 10
		}
	},
	# level 1
	{"camera": {
		"spawn_interval": 8,
		"pos_list": [Vector2(100, 250)]
		},
	"bubble": {
		"spawn_interval": 2,
		"urgency_options": [false],
		"countdown_lower": 6,
		"countdown_upper": 10
		}
	},
	# level 2
	{"camera": {
		"spawn_interval": 6,
		"pos_list": [Vector2(100, 250), Vector2(566, 335), Vector2(333, 262), Vector2(323, 254),
		Vector2(632, 213), Vector2(427, 352), Vector2(202, 277), Vector2(681, 346)]
		},
	"bubble": {
		"spawn_interval": 2,
		"urgency_options": [false],
		"countdown_lower": 6,
		"countdown_upper": 10
		}
	},
	# level 3
	{"camera": {
		"spawn_interval": 6,
		"pos_list": [Vector2(100, 250), Vector2(566, 335), Vector2(333, 262), Vector2(323, 254),
		Vector2(632, 213), Vector2(427, 352), Vector2(202, 277), Vector2(681, 346)]
		},
	"bubble": {
		"spawn_interval": 2,
		"urgency_options": [false, false, true],
		"countdown_lower": 6,
		"countdown_upper": 10
		}
	},
	# level 4
	{"camera": {
		"spawn_interval": 5,
		"pos_list": [Vector2(100, 250), Vector2(566, 335), Vector2(333, 262), Vector2(323, 254),
		Vector2(632, 213), Vector2(427, 352), Vector2(202, 277), Vector2(681, 346)]
		},
	"bubble": {
		"spawn_interval": 1.5,
		"urgency_options": [false, true],
		"countdown_lower": 6,
		"countdown_upper": 10
		}
	},
	{"camera": {
		"spawn_interval": 5,
		"pos_list": [Vector2(100, 250), Vector2(566, 335), Vector2(333, 262), Vector2(323, 254),
		Vector2(632, 213), Vector2(427, 352), Vector2(202, 277), Vector2(681, 346)]
		},
	"bubble": {
		"spawn_interval": 1.5,
		"urgency_options": [false, true],
		"countdown_lower": 4,
		"countdown_upper": 8
		}
	}
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# level progression
	level_timer.connect("timeout", Callable(self, "_on_level_timeout"))
	cooldown_timer.connect("timeout", Callable(self, "_on_day_end"))
	
	# game dynamics
	bubble_control.connect("update_anxiety", Callable(anxiety_control, "_on_bubble_cnt_update"))
	bubble_control.connect("update_bubble_cleared", Callable(self, "_on_update_bubble_cleared"))
	camera_control.connect("update_photo_taken", Callable(self, "_on_update_photo_taken"))
	wine_control.connect("wine_ingested", Callable(anxiety_control, "_on_wine_ingestion"))
	wine_control.connect("wine_ingested", Callable(bathroom_control, "_on_wine_ingestion"))
	wine_control.connect("getting_tipsy", Callable(self, "_on_getting_tipsy"))
	bathroom_control.connect("bathroom_break", Callable(self, "_on_bathroom_break_start"))
	bathroom.connect("bathroom_completed", Callable(self, "_on_bathroom_break_completed"))
	
	# game over signals
	anxiety_control.connect("game_over", Callable(self, "_on_game_over"))
	bathroom_control.connect("game_over", Callable(self, "_on_game_over"))
	camera_control.connect("game_over", Callable(self, "_on_game_over"))
	bubble_control.connect("game_over", Callable(self, "_on_game_over"))
	wine_control.connect("game_over", Callable(self, "_on_game_over"))
	
	
	bathroom.position = Vector2(0, 0)
	camera_control.position = Vector2(0, 0)
	bubble_control.position = Vector2(0, 0)
	
	level_timer.one_shot = true
	level_timer.wait_time = level_duration
	
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = 3
	
	
func start_game():
	
	# reset everything
	level_timer.stop()
	cooldown_timer.stop()
	
	bathroom.hide()
	bathroom_control.reset()
	status_display.reset()
	
	num_bubbles_cleared = 0
	num_photo_taken = 0
	is_in_bathroom = false
	day_end = false
	is_over = false
	
	# start level 0
	current_level = 0
	_set_level_data(current_level)
	level_timer.start()
	
	bubble_control.start_game()
	camera_control.start_game()
	anxiety_control.start_game()
	wine_control.start_game()
	
	show()


func _set_level_data(current_level):
	var camera_params = level_data[current_level]["camera"]
	camera_control.update_level_params(camera_params)
	var bubble_params = level_data[current_level]["bubble"]
	bubble_control.update_level_params(bubble_params)
	

func _on_level_timeout():
	
	current_level += 1
	if current_level >= len(level_data):
		bubble_control.stop_spawning()
		cooldown_timer.start()
		
	else:
		_set_level_data(current_level)
		level_timer.start()
		# to do: replace with real clock display
		status_display.set_game_clock(current_level)


func _on_day_end():
	day_end = true
	camera_control.day_end = true
	bubble_control.day_end = true
	# if the player is not occupied, immediately end game
	if !is_in_bathroom:
		if !camera_control.is_shooting:
			if bubble_control.total_bubbles == 0:
				_on_game_over("success")
	# if the player is in the middle of something
	# bathroom, photo shoot, bubble spawns
	# the completion of these events will trigger game success signal
	

func _on_update_bubble_cleared(num_bubbles):
	num_bubbles_cleared = num_bubbles
	status_display.set_bubble_count(num_bubbles)


func _on_update_photo_taken(num_photos):
	num_photo_taken = num_photos
	status_display.set_photo_count(num_photos)
	

# triggered by bathroom control button click
func _on_bathroom_break_start():
	
	is_in_bathroom = true
	
	bathroom.take_break()
	anxiety_control.start_bathroom_break()
	camera_control.pause_camera()
	bubble_control.pause_convo()
	
	remove_child(anxiety_control)
	bathroom.add_child(anxiety_control)


# triggered by bathroom signal
func _on_bathroom_break_completed():
	
	is_in_bathroom = false

	bathroom.remove_child(anxiety_control)
	add_child(anxiety_control)
	
	if day_end:
		_on_game_over("success")
	
	else:
		bathroom_control.reset()
		anxiety_control.return_from_break()
		camera_control.resume_camera()
		bubble_control.resume_convo()


func _on_getting_tipsy():
	tipsy.play("tipsy")


# show game over GUD
func _on_game_over(reason):
	# pause everything
	anxiety_control.end_game()
	bathroom_control.end_game()
	camera_control.end_game()
	bubble_control.end_game()
	level_timer.stop()
	cooldown_timer.stop()
	tipsy.stop()
	
	if !is_over:
		is_over = true
		var final_dataset = {
			"reason": reason,
			"bubble_cleared": num_bubbles_cleared,
			"photo_taken": num_photo_taken
		}
		emit_signal("game_over", final_dataset)
