extends Node2D


signal bathroom_completed()


@onready var audio = $Audio
@onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.connect("timeout", Callable(self, "_on_bathroom_timeout"))
	
	timer.one_shot = true
	timer.wait_time = 8
	
	hide()


func take_break():
	show()
	audio.play()
	timer.start()


func _on_bathroom_timeout():
	emit_signal("bathroom_completed")
	audio.stop()
	hide()
