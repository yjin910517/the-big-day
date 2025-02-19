extends Node2D


@onready var camera = $Camera
@onready var flashlight = $Flashlight
@onready var spawn_timer = $SpawnTimer

var camera_pos_list = [ 
	Vector2(160, 210),
	Vector2(600, 300),
	Vector2(600, 210)
]

var success_flag = false
# to do: display this in status bar
var total_photo_taken = 0
var spawn_interval = 5 # level progression params


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.connect("camera_timeout", Callable(self, "_on_camera_timeout"))
	flashlight.connect("flashlight_completed", Callable(self, "_on_flashlight_completed"))
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timeout"))
	
	flashlight.hide()
	camera.hide()
	
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = true
	spawn_timer.start()


# spawn new photo request
func _on_spawn_timeout():
	spawn()
	spawn_timer.wait_time = spawn_interval
	

func spawn():
	var camera_pos = camera_pos_list.pick_random()
	camera.show_camera(camera_pos)


# for level progression
func update_spawn_interval(new_interval):
	spawn_interval = new_interval

# for bathroom break
func pause_camera():
	spawn_timer.paused = true
	# to do: check whether camera is active, call pause method on camera
	

func resume_camera():
	spawn_timer.paused = false
	# to do: check whether camera is active, call resume method on camera


# record photo status and show flashlight
func _on_camera_timeout(is_success):
	success_flag = is_success
	flashlight.flash()


func _on_flashlight_completed():
	if success_flag:
		spawn_timer.start()
		# display the success icon for a second
		await get_tree().create_timer(1).timeout
		camera.hide()
	else: 
		camera.hide()
		spawn_timer.stop()
		print("game over")
		# to do: emit game over signal
		# full screen GUD game over transition scene of a bad photo
