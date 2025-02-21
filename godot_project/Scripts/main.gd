extends Node2D


@onready var audio = $AmbienceSound
@onready var intro = $Intro
@onready var lobby = $LobbyRoom
@onready var gameover = $GameOver
@onready var achievements = $Achievements


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	intro.connect("intro_completed", Callable(self, "_on_intro_completed"))
	lobby.connect("game_over", Callable(self, "_on_game_over"))
	gameover.connect("show_achievements", Callable(self, "_on_show_achievements"))
	achievements.connect("play_again", Callable(self, "_on_replay_game"))
	
	intro.position = Vector2(0, 0)
	lobby.position = Vector2(0, 0)
	gameover.position = Vector2(0, 0)
	achievements.position = Vector2(0, 0)
	
	intro.show()
	audio.play()
	
	lobby.hide()
	gameover.hide()
	achievements.hide()
	

func _on_intro_completed():
	intro.hide()
	lobby.start_game()
	

func _on_game_over(final_dataset):
	var reason = final_dataset["reason"]
	audio.stop()
	# to do: add freeze time for a blackscreen for transition?
	gameover.display_gud(final_dataset)


func _on_show_achievements(reason):
	gameover.hide()
	achievements.update_achievements(reason)
	achievements.show()


func _on_replay_game():
	achievements.hide()
	audio.play()
	lobby.start_game()
