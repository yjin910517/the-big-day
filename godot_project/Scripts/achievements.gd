extends Node2D


signal play_again()


@onready var retry = $RetryButton
@onready var success = $SuccessTile
@onready var blackout = $BlackoutTile
@onready var bad_photo = $BadPhotoTile
@onready var anxiety_attack = $AnxietyTile
@onready var offended_guest = $AngryTile
@onready var bathroom_emergency = $FullBladderTile

var revealed_list


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


func update_achievements(reason):
	if !revealed_list.has(reason):
		revealed_list.append(reason)
		
		# to do: play animation to delay the reveal
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


func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("play_again")
