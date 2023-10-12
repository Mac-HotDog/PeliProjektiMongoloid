extends Node3D


var arrow = preload("res://Scenes/level_nodes/arrow.tscn")
@export var startDelay = 0
var random_int = 1 + randi() % (5 + 1 - 1)
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

func shoot():
	#await get_tree().create_timer(startDelay).timeout
	var projectile = arrow.instantiate()
	add_child(projectile)
	#projectile.top_level = true
	var direction_to_marker = $Marker3D.global_transform.origin - projectile.global_transform.origin
	var velocity = direction_to_marker.normalized() * 10
	projectile.linear_velocity = velocity

func _on_timer_timeout():
	shoot()
	$AudioStreamPlayer3D.play()
