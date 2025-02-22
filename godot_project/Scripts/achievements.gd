extends Node2D


signal play_again()


@onready var retry = $RetryButton
@onready var btn_icon = $RetryButton/Icon
@onready var btn_label = $RetryButton/Label
@onready var success = $SuccessTile
@onready var blackout = $BlackoutTile
@onready var bad_photo = $BadPhotoTile
@onready var anxiety_attack = $AnxietyTile
@onready var offended_guest = $AngryTile
@onready var bathroom_emergency = $FullBladderTile

var revealed_list
var is_reacting


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	retry.connect("gui_input", Callable(self, "_on_button_gui_input"))
	
	success.frame = 0
	blackout.frame = 0
	bad_photo.frame = 0
	anxiety_attack.frame = 0
	offended_guest.frame = 0
	bathroom_emergency.frame = 0
	
	revealed_list = []
	is_reacting = true


func update_achievements(reason):
	if !revealed_list.has(reason):
		revealed_list.append(reason)
		
		if reason == "success":
			success.frame = 1
		elif reason == "blackout":
			blackout.frame = 1
		elif reason == "bad_photo":
			bad_photo.frame = 1
		elif reason == "anxiety_attack":
			anxiety_attack.frame = 1
		elif reason == "offended_guest":
			offended_guest.frame = 1
		elif reason == "bathroom_emergency":
			bathroom_emergency.frame = 1
	
	if len(revealed_list) == 6:
		_display_tropy()


func _display_tropy():
	btn_icon.frame = 1
	btn_label.text = "100% Done"
	is_reacting = false
	

func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_reacting:
			emit_signal("play_again")
