extends Node2D

@onready var game_clock = $GameClock
@onready var bubble_label = $BubbleLabel
@onready var photo_label = $PhotoLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func reset():
	# to do: replace with clock display
	game_clock.text = str(0)
	
	bubble_label.text = str(0)
	photo_label.text = str(0)


func set_game_clock(level):
	game_clock.text = str(level)


func set_bubble_count(num):
	bubble_label.text = str(num)


func set_photo_count(num):
	photo_label.text = str(num)
