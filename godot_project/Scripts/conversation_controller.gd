extends Node2D


signal game_over(fail_reason)
signal update_anxiety(num_bubbles)


@onready var audio = $ClearSound
@onready var spawn_timer = $SpawnTimer


var BubbleScene = preload("res://Scenes/Conversation.tscn")


# data for randomization
var bubble_styles = ["a", "b"]
var freeze_styles= [1]
var active_frames = [1, 2, 3]
var gibbers = [
	preload("res://Audios/gibbers/435876_gibber_1.wav"),
	preload("res://Audios/gibbers/435876_gibber_2.wav")
]


var total_bubbles = 0 

# to do: count cleared bubbles for achievements?


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timeout"))
	
	_spawn_conversation()
	start_spawning(3)


func start_spawning(t):
	spawn_timer.wait_time = t # level progress params
	spawn_timer.start()


# for bathroom break
func pause_convo():
	spawn_timer.paused = true
	# to do: pause all bubbles
	# how to pause freezing bubbles? Turn off their is_urgent flag for good?
	# var bubbles = get_tree().get_nodes_in_group("Bubbles")
	
	
func resume_convo():
	spawn_timer.paused = false
	# to do: resume all convo
	

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
	
	var chosen_freeze_time = randi_range(2, 4) # level progress params
	
	var picked_style = bubble_styles.pick_random()
	var picked_freeze = "talking_" + picked_style + str(freeze_styles.pick_random())
	var picked_active = "active_" + picked_style
	var picked_frame = active_frames.pick_random()
	var picked_gibber = gibbers.pick_random()
	
	var chosen_urgency = [false].pick_random() # level progress params
	var chosen_countdown
	if chosen_urgency:
		chosen_countdown = randi_range(8, 12) # level progress params
	
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


func _on_bubble_cleared(bubble_node):
	audio.play()
	bubble_node.queue_free()
	total_bubbles -= 1
	emit_signal("update_anxiety", total_bubbles)


func _on_bubble_timeout(bubble_node):
	print("game over, bubble time out")
	spawn_timer.stop()
	# to do: add a top layer angry face at the position of time out bubble
	# delete all other bubbles and highlight the failed one
	# trigger game over scene
	emit_signal("game_over", "offended_guest")
