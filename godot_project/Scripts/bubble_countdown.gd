extends Control


signal conversation_failed()


@onready var timer = $Progress

var is_running: bool
var countdown_time: float
var time_passed: float


func _ready():
	pass
	

func initiate_countdown(countdown_val):

	countdown_time = countdown_val
	time_passed = 0
	timer.step = 0.01  # Set the step small enough to detect delta change
	timer.max_value = countdown_time # Set the max value of the timer
	timer.value = 0
	
	set_process(true)
	is_running = true
		

# pause countdown for bathroom breaks
func pause_countdown():
	is_running = false


# resume countdown after bathroom breaks
func resume_countdown():
	is_running = true


# update time elapsed
func _process(delta):
	
	if is_running:
		if time_passed < countdown_time:
			time_passed += delta
			timer.value = time_passed
		else:
			set_process(false)  # Stop updating when time is up
			_on_time_out()       # Handle timeout logic

			
# emit timeout signal to parent bubble 
func _on_time_out():
	emit_signal("conversation_failed")
