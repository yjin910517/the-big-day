extends Node2D


@onready var lobby = $LobbyRoom
@onready var gameover = $GameOverGUD

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
	lobby.connect("game_over", Callable(self, "_on_game_over"))
	
	gameover.position = Vector2(0, 0)
	lobby.position = Vector2(0, 0)
	gameover.hide()
	lobby.start_game()
	

func _on_game_over(reason):
	achievements[reason] = true
	gameover.display_gud(reason)
