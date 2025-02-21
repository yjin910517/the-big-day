extends Node2D


@onready var audio = $AmbienceSound
@onready var intro = $Intro
@onready var lobby = $LobbyRoom
@onready var gameover = $GameOver


var achievements = {
	"anxiety_attack": false,
	"bathroom_emergency": false,
	"bad_photo": false,
	"offended_guest": false,
	"blackout": false,
	"perfect_day": false
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	intro.connect("intro_completed", Callable(self, "_on_intro_completed"))
	lobby.connect("game_over", Callable(self, "_on_game_over"))
	gameover.connect("show_achievements", Callable(self, "_on_show_achievements"))
	
	intro.position = Vector2(0, 0)
	gameover.position = Vector2(0, 0)
	lobby.position = Vector2(0, 0)
	
	intro.show()
	audio.play()
	
	lobby.hide()
	gameover.hide()
	

func _on_intro_completed():
	intro.hide()
	lobby.start_game()
	

func _on_game_over(final_dataset):
	var reason = final_dataset["reason"]
	# to do : change data type to differentiate new achievements
	achievements[reason] = true 
	# to do: add freeze time for a blackscreen for transition?
	# differentiate logic for success and fail?
	# stop ambience sound
	gameover.display_gud(final_dataset)


func _on_show_achievements():
	print("show achievements")
