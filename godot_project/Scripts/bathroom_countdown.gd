extends Control


signal bladder_exploded()


@onready var timer = $Progress

var countdown_time = 10
var time_passed: float


func _ready():
	reset_countdown()
	

func initiate_countdown():
	
	set_process(true)
	show()


func reset_countdown():
	
	time_passed = 0
	timer.step = 0.01  # Set the step small enough to detect delta change
	timer.max_value = countdown_time # Set the max value of the timer
	timer.value = 0
	
	set_process(false)
	hide()


# update time elapsed
func _process(delta):
	
	if time_passed < countdown_time:
		time_passed += delta
		timer.value = time_passed
	else:
		set_process(false)  # Stop updating when time is up
		_on_time_out()      # Handle timeout logic

			
# emit timeout signal to parent bubble 
func _on_time_out():
	emit_signal("bladder_exploded")
