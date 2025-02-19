extends Node2D


signal bubble_timeout(bubble_node)
signal bubble_cleared(bubble_node)


@onready var bubble = $Bubble
@onready var freeze_timer = $FreezeTimer
@onready var audio = $Gibber
@onready var movement = $AnimationPlayer
@onready var countdown = $CountdownDisplay
@onready var click_detect = $Bubble/ClickDetect


var is_reacting: bool
var active_display_anime: String
var active_display_frame: int
var is_urgent: bool
var countdown_time: int


func _ready() -> void:
	freeze_timer.connect("timeout", Callable(self, "_on_freeze_timeout"))
	click_detect.connect("gui_input", Callable(self, "_on_bubble_gui_input"))
	countdown.connect("conversation_failed", Callable(self, "_on_countdown_timeout"))


# Set up bubble display by bubble controller
func initiate_bubble(bubble_data):
	position = bubble_data["position"]

	# initiate freeze state
	is_reacting = false
	freeze_timer.wait_time = bubble_data["freeze_time"]
	freeze_timer.one_shot = true
	
	freeze_timer.start()
	bubble.play(bubble_data["freeze_anime"])
	audio.stream = bubble_data["gibber"]
	audio.play()
	
	# save active bubble params for later use
	active_display_anime = bubble_data["active_anime"]
	active_display_frame = bubble_data["display_frame"]
	
	countdown.hide()
	is_urgent = bubble_data["is_urgent"]
	if is_urgent:
		countdown_time = bubble_data["countdown_time"]


func _on_freeze_timeout():
	
	_activate_bubble()


func _activate_bubble():
	
	is_reacting = true
	
	bubble.play(active_display_anime)
	bubble.stop()
	bubble.frame = active_display_frame
	
	movement.play("bubble_dynamic")
	
	if is_urgent:
		countdown.show()
		countdown.initiate_countdown(countdown_time)


# for click interaction
func _on_bubble_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_reacting:
			emit_signal("bubble_cleared", self)


# for timeout game over
func _on_countdown_timeout():
	emit_signal("bubble_timeout", self)
	

# for bathroom break
func pause_bubble():
	countdown.pause_countdown()


func resume_bubble():
	countdown.resume_countdown()
	
