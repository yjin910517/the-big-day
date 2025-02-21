extends Node2D


signal wine_ingested()
signal game_over(failed_reason)


@onready var wine_button = $WineButton
@onready var click_detect = $WineButton/ClickDetect
@onready var progress = $TipsyBar
@onready var audio = $Audio

var num_drank
var max_drink = 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	click_detect.connect("gui_input", Callable(self, "_on_button_gui_input"))
	
	progress.max_value = max_drink
	progress.step = 1


func start_game():
	num_drank = 0
	progress.value = num_drank


func _on_button_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		audio.play()
		num_drank += 1
		progress.value = num_drank
		
		if num_drank <= max_drink:
			emit_signal("wine_ingested")

		if num_drank == max_drink:
			pass
			# to do: show tipsy visual effect
			# an animation player with mutliple track on bars position?
		if num_drank > max_drink:
			emit_signal("game_over", "blackout")
			
