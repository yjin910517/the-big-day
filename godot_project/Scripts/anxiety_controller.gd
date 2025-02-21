extends Node2D


signal game_over(fail_reason)


@onready var progress = $AnxietyBar

var anxiety_max = 100
var total_anxiety
var anxiety_velocity
var is_reacting
var velocity_cache


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	progress.max_value = anxiety_max
	progress.step = 1
	

func start_game():
	total_anxiety = 0
	progress.value = total_anxiety
	anxiety_velocity = 0
	is_reacting = true
	progress.set_process(true)


# called when game over
func end_game():
	is_reacting = false
	progress.set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_reacting:
		total_anxiety += delta * anxiety_velocity
		_update_bar_progress()


# update bar display 
func _update_bar_progress():
	if total_anxiety >= anxiety_max:
		progress.value = anxiety_max
		emit_signal("game_over", "anxiety_attack")
	elif total_anxiety < 0:
		total_anxiety = 0
		progress.value = total_anxiety
	else:
		progress.value = total_anxiety	


# connected to bubble controller signal by main
func _on_bubble_cnt_update(num_bubbles):
	anxiety_velocity = log(num_bubbles ** 0.5 + 1) * 2
	

# connected to wine controller signal by main
func _on_wine_ingestion():
	total_anxiety = total_anxiety * 2 / 3
	

# for bathroom break
func start_bathroom_break():
	velocity_cache = anxiety_velocity
	anxiety_velocity = -1
	

func return_from_break():
	anxiety_velocity = velocity_cache
	
