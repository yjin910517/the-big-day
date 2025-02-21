extends Node2D


signal update_anxiety(num_bubbles)
signal update_bubble_cleared(num_cleared)
signal game_over(fail_reason)


@onready var audio = $ClearSound
@onready var spawn_timer = $SpawnTimer


var BubbleScene = preload("res://Scenes/Conversation.tscn")


# data for randomization
var bubble_styles = ["a", "b"]
var freeze_styles= [1]
var active_frames = [1, 2, 3]
var gibbers = [
	preload("res://Audios/gibbers/435876_gibber_1.wav"),
	preload("res://Audios/gibbers/435876_gibber_2.wav"),
	preload("res://Audios/gibbers/152727_gibber_1.wav"),
	preload("res://Audios/gibbers/152727_gibber_2.wav"),
	preload("res://Audios/gibbers/152727_gibber_3.wav"),
]

# level parameters
var spawn_interval
var urgency_options
var countdown_lower
var countdown_upper

# game progress trackers
var total_bubbles # for anxiety velocity 
var cleared_bubbles # for game achievement display


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timeout"))


func start_game():
	# initiate all parameters 
	total_bubbles = 0
	cleared_bubbles = 0
	
	_spawn_conversation()
	start_spawning(spawn_interval)


func update_level_params(new_params):
	spawn_interval = new_params["spawn_interval"]
	urgency_options = new_params["urgency_options"]
	countdown_lower = new_params["countdown_lower"]
	countdown_upper = new_params["countdown_upper"]


# clear out current game display
func end_game():
	# clear bubbles
	var bubbles = get_tree().get_nodes_in_group("Bubbles")
	for bub in bubbles:
		bub.queue_free()
	
	# stop timer
	spawn_timer.stop()
	

func start_spawning(t):
	spawn_timer.wait_time = t
	spawn_timer.start()


func _on_spawn_timeout():
	_spawn_conversation()


func _spawn_conversation():

	# Instantiate bubble
	var new_bubble = BubbleScene.instantiate()
	add_child(new_bubble)
	new_bubble.add_to_group("Bubbles")
	
	new_bubble.connect("bubble_cleared", Callable(self, "_on_bubble_cleared"))
	new_bubble.connect("bubble_timeout", Callable(self, "_on_bubble_timeout"))
	
	var bubble_data = _generate_bubble_data()
	new_bubble.initiate_bubble(bubble_data)
	new_bubble.show()
	
	total_bubbles += 1
	emit_signal("update_anxiety", total_bubbles)
	

# generate random parameters for new bubble spawn
func _generate_bubble_data():
	var spawn_pos_x = randi_range(6, 26) * 30
	var spawn_pos_y = randi_range(20, 35) * 10
	
	var chosen_freeze_time = randi_range(1, 3)
	
	var picked_style = bubble_styles.pick_random()
	var picked_freeze = "talking_" + picked_style + str(freeze_styles.pick_random())
	var picked_active = "active_" + picked_style
	var picked_frame = active_frames.pick_random()
	var picked_gibber = gibbers.pick_random()
	
	var chosen_urgency = urgency_options.pick_random() # level progress params
	var chosen_countdown
	if chosen_urgency:
		chosen_countdown = randi_range(countdown_lower, countdown_upper) # level progress params
	
	var bubble_data = {
		"position": Vector2(spawn_pos_x, spawn_pos_y), 
		"freeze_anime": picked_freeze,
		"freeze_time": chosen_freeze_time,
		"active_anime": picked_active,
		"display_frame": picked_frame,
		"gibber": picked_gibber,
		"is_urgent": chosen_urgency, 
		"countdown_time": chosen_countdown	
	}
	
	return bubble_data


# for bathroom break
func pause_convo():
	spawn_timer.paused = true
	var bubbles = get_tree().get_nodes_in_group("Bubbles")
	for bub in bubbles:
		if bub.is_urgent:
			if bub.is_reacting:
				bub.pause_bubble()
			else:
				bub.is_urgent = false

	
func resume_convo():
	spawn_timer.paused = false
	var bubbles = get_tree().get_nodes_in_group("Bubbles")
	for bub in bubbles:
		if bub.is_urgent:
			if bub.is_active:
				bub.resume_bubble()	
				

func _on_bubble_cleared(bubble_node):
	audio.play()
	bubble_node.queue_free()
	
	cleared_bubbles += 1
	emit_signal("update_bubble_cleared", cleared_bubbles)
	
	total_bubbles -= 1
	emit_signal("update_anxiety", total_bubbles)


func _on_bubble_timeout(bubble_node):
	emit_signal("game_over", "offended_guest")
