extends Node2D


signal flashlight_completed()


@onready var flash_anime = $AnimationPlayer
@onready var audio = $Audio


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flash_anime.connect("animation_finished", Callable(self, "_on_flashlight_finished"))


func flash():
	show()
	flash_anime.play("flashlight")
	audio.play()
	

func _on_flashlight_finished(anim_name):
	if anim_name == "flashlight":
		emit_signal("flashlight_completed")
		hide()
	
