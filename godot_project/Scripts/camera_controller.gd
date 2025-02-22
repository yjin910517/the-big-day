extends Node2D


signal update_photo_taken(num_photo)
signal game_over(fail_reason)


@onready var camera = $Camera
@onready var flashlight = $Flashlight
@onready var spawn_timer = $SpawnTimer

# level parameters
var camera_pos_list
var spawn_interval

# node status 
var is_shooting
var day_end
var success_flag
var total_photo_taken


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.connect("camera_timeout", Callable(self, "_on_camera_timeout"))
	flashlight.connect("flashlight_completed", Callable(self, "_on_flashlight_completed"))
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timeout"))

	hide()


func start_game():
	flashlight.hide()
	camera.hide()
	
	# reset all parameters
	is_shooting = false
	day_end = false
	success_flag = false
	total_photo_taken = 0
	
	spawn_timer.stop()
	spawn_timer.paused = false
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = true
	spawn_timer.start()
	
	show()


func update_level_params(new_params):
	spawn_interval = new_params["spawn_interval"]
	camera_pos_list = new_params["pos_list"]


func end_game():
	camera.hide()
	spawn_timer.stop()
	if is_shooting:
		camera.pause_camera()


# spawn new photo request
func _on_spawn_timeout():
	spawn()
	spawn_timer.wait_time = spawn_interval
	

func spawn():
	var camera_pos = camera_pos_list.pick_random() # level params controlled by main
	camera.show_camera(camera_pos)
	is_shooting = true


# for level progression
func update_level_data(new_interval, new_pos_list):
	spawn_interval = new_interval
	camera_pos_list = new_pos_list


# for bathroom break
func pause_camera():
	spawn_timer.paused = true
	if is_shooting:
		camera.pause_camera()
	

func resume_camera():
	spawn_timer.paused = false
	if is_shooting:
		camera.resume_camera()


# record photo status and show flashlight
func _on_camera_timeout(is_success):
	success_flag = is_success
	flashlight.flash()


func _on_flashlight_completed():
	
	is_shooting = false
	
	if success_flag:
		total_photo_taken += 1
		emit_signal("update_photo_taken", total_photo_taken)
		
		# restart next cycle if the game is not ended
		if !day_end:
			spawn_timer.start()
			# display the success icon for a second
			await get_tree().create_timer(1).timeout
			camera.hide()
		# end game if the day has ended
		else:
			emit_signal("game_over", "success")
			
	else: 
		emit_signal("game_over", "bad_photo")
