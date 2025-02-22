extends Node2D


signal show_achievements()


@onready var timer = $Timer
@onready var audio = $Audio
@onready var background = $Background
@onready var bubbles = $Stats/BubbleLabel
@onready var photos = $Stats/PhotoLabel
@onready var icon = $Icon
@onready var label = $Label
@onready var next_btn = $NextButton
@onready var click_detect = $NextButton/ClickDetect

var reason

var outcome_assets = {
	"anxiety_attack": {
		"audio":preload("res://Audios/547961__scream.wav"),
		"background": "normal",
		"icon": preload("res://Arts/game_over/anxiety_icon.png"),
		"text": "Too much pressure. You had a mental breakdown."
	},
	"bathroom_emergency": {
		"audio":preload("res://Audios/242503__fail.wav"),
		"background": "normal",
		"icon": preload("res://Arts/game_over/bathroom_icon.png"),
		"text": "You are too distressed with a full bladder."
	},
	"bad_photo": {
		"audio":preload("res://Audios/772690__oh_no.wav"),
		"background": "normal",
		"icon": preload("res://Arts/game_over/bad_photo.png"),
		"text": "Oh no! You didn't pose for the camera."
	},
	"offended_guest": {
		"audio":preload("res://Audios/527737_angry.wav"),
		"background": "normal",
		"icon": preload("res://Arts/game_over/angry_icon.png"),
		"text": "Your guest was offended because you ignored them."
	},
	"blackout": {
		"audio":preload("res://Audios/242503__fail.wav"),
		"background": "blackout",
		"icon": preload("res://Arts/game_over/wine_icon.png"),
		"text": "You had too much wine and you were drunk."
	},
	"success": {
		"audio":preload("res://Audios/274181__win.wav"),
		"background": "success",
		"icon": preload("res://Arts/game_over/success_icon.png"),
		"text": "You've made it! Everything is perfect."
	}
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	click_detect.connect("gui_input", Callable(self, "_on_button_gui_input"))
	
	next_btn.hide()


func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("show_achievements", reason)


func display_gud(dataset):
	
	next_btn.hide()
	
	# display final score
	var total_bubbles = dataset["bubble_cleared"]
	var total_photos = dataset["photo_taken"]
	bubbles.text = str(total_bubbles)
	photos.text = str(total_photos)
	
	# update outcome info
	reason = dataset["reason"]
	var display_data = outcome_assets[reason]
	audio.stream = display_data["audio"]
	audio.play()
	background.play(display_data["background"])
	icon.texture = display_data["icon"]
	label.text = display_data["text"]
	
	show()
	
	# show next button
	await get_tree().create_timer(3).timeout
	next_btn.show()
