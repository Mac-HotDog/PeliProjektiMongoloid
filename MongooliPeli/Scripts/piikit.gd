extends Node3D

var laskin = 0
@onready var area = $Area3D

var random_float = 1 + randf() * (3 - 1)
func _ready():
	# Create a new Timer instance
	var timer = Timer.new()

	# Set the timer properties
	timer.wait_time = random_float  # The timer will wait for 5 seconds
	timer.one_shot = false  # This timer will only timeout once

	# Connect the timeout signal to a callback function
	timer.timeout.connect(_on_timer_timeout)

	# Add the timer as a child of the current node
	add_child(timer)

	# Start the timer
	timer.start()

func _on_timer_timeout():
	
	if laskin == 0:
		laskin +=1
		hide()
		area.set_monitorable(false)
		
	else:
		laskin += -1
		show()
		area.set_monitorable(true)
		area.set_monitoring(false)
		area.set_monitoring(true)
