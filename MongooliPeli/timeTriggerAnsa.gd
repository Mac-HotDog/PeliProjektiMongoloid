extends Node3D

@export var wait = 2
@export var waitHide = 1
@onready var dildo = $dildo
@onready var area = $dildo/Area3D
@onready var coll = $dildo/Area3D/CollisionShape3D

func _ready():
	# Create a new Timer instance
	var timer = Timer.new()

	# Set the timer properties
	timer.wait_time = wait  # The timer will wait for 5 seconds
	timer.one_shot = false  # This timer will only timeout once

	# Connect the timeout signal to a callback function
	timer.timeout.connect(_on_timer_timeout)

	# Add the timer as a child of the current node
	add_child(timer)

	# Start the timer
	timer.start()
	
	
	
	
func _on_timer_timeout():
	dildo.show()
	area.set_monitorable(true)
	area.set_monitoring(false)
	area.set_monitoring(true)
	await get_tree().create_timer(waitHide).timeout
	dildo.hide()
	area.set_monitorable(false)
	$click.play()
