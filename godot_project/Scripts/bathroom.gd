extends Node2D


signal bathroom_completed()


@onready var audio = $Audio


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	hide()


func take_break():
	
	show()
	audio.play()
	await get_tree().create_timer(8).timeout
	emit_signal("bathroom_completed")
	
	hide()
