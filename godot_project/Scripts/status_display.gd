extends Node2D


@onready var bubble_label = $BubbleLabel
@onready var photo_label = $PhotoLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_bubble_count(num):
	bubble_label.text = str(num)


func set_photo_count(num):
	photo_label.text = str(num)
