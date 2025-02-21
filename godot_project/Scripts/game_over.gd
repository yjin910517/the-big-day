extends Node2D


@onready var audio = $Audio
@onready var background = $Background
@onready var icon = $Icon
@onready var label = $Label

var fail_assets = {
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
		"audio":preload("res://Audios/242503__fail.wav"),
		"background": "normal",
		"icon": preload("res://Arts/game_over/bad_photo.png"),
		"text": "Oh no! You didn't pose for the camera."
	},
	"offended_guest": {
		"audio":preload("res://Audios/242503__fail.wav"),
		"background": "normal",
		"icon": preload("res://Arts/game_over/angry_icon.png"),
		"text": "Your guest was offended because you ignored them."
	},
	"blackout": {
		"audio":preload("res://Audios/242503__fail.wav"),
		"background": "blackout",
		"icon": preload("res://Arts/game_over/wine_icon.png"),
		"text": "You had too much wine and you were drunk."
	}
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func display_gud(reason):
	var fail_data = fail_assets[reason]
	audio.stream = fail_data["audio"]
	audio.play()
	background.play(fail_data["background"])
	icon.texture = fail_data["icon"]
	label.text = fail_data["text"]
	
	show()
	
	# to do: add await time
	# then turn on to detect click for next page
