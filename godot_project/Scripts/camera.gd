extends Node2D


signal camera_timeout(is_success)

var smiles = [
	preload("res://Audios/camera/smile_1.wav"),
	preload("res://Audios/camera/smile_2.wav"),
	preload("res://Audios/camera/smile_3.wav")
]



@onready var pose_control = $PoseControl
@onready var display_sprite = $CameraIcon
@onready var countdown = $Countdown
@onready var audio = $Audio

var is_mouse_held = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pose_control.connect("gui_input", Callable(self, "_on_camera_gui_input"))
	countdown.connect("animation_finished", Callable(self, "_on_camera_timeout"))


# activate camera display
func show_camera(pos):
	
	position = pos
	audio.stream = smiles.pick_random()
	audio.play()
	display_sprite.frame = 0
	pose_control.show()
	countdown.play("default")
	
	show()


# for bathroom break
func pause_camera():
	countdown.stop()


# restart countdown after bathroom break
func resume_camera():
	countdown.play("default")


# show smile pose when hold click
func _on_camera_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if is_mouse_held == false:
					is_mouse_held = true
					display_sprite.frame = 1
			else:
				if is_mouse_held:
					is_mouse_held = false
					display_sprite.frame = 0


# send outcome to controller
func _on_camera_timeout():
	
	# check if smile is posed
	if is_mouse_held:
		emit_signal("camera_timeout", true)
		display_sprite.frame = 2
	else:
		emit_signal("camera_timeout", false)
	
	# reset mouse control
	pose_control.hide()
	is_mouse_held = false
