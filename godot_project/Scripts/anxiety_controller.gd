extends Node2D


@onready var progress = $AnxietyBar

var total_anxiety = 0
var anxiety_velocity = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	progress.value = 0
	progress.set_process(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_anxiety += delta * anxiety_velocity
	# to do: check if the total value hits max
	progress.value = total_anxiety


# connected to bubble controller signal by main
func _on_bubble_cnt_update(num_bubbles):
	anxiety_velocity = log(num_bubbles ** 0.5 + 1) * 2 # change const 2 by tipsy level
	print("new velocity ", anxiety_velocity)
