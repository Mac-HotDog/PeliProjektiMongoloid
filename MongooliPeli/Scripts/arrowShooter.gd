extends Node3D


var arrow = preload("res://Scenes/level_nodes/arrow.tscn")

@export var startDelay = 0.0
@export var shootTimer = 2.0

var random_int = 1 + randi() % (5 + 1 - 1)
var random_float = 2 + randf() * (4 - 2)

var alert_timer = random_float -0.5
var timer2

func _ready():
	# Create a new Timer instance
	var timer = Timer.new()

	# Set the timer properties
	timer.wait_time = shootTimer  # The timer will wait for 5 seconds
	timer.one_shot = false  # This timer will only timeout once

	# Connect the timeout signal to a callback function
	timer.timeout.connect(_on_timer_timeout)

	# Add the timer as a child of the current node
	add_child(timer)
	
	await get_tree().create_timer(startDelay).timeout
	# Start the timer
	timer.start()
	
	timer2 = Timer.new()
	timer2.wait_time = alert_timer  # The timer will wait for 5 seconds
	timer2.one_shot = true  # This timer will only timeout once

	# Connect the timeout signal to a callback function
	timer2.timeout.connect(_show_huutomerkki)

	# Add the timer as a child of the current node
	add_child(timer2)
	
	

func shoot():
	timer2.start()
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
	
func _show_huutomerkki():
	$Sprite3D.show()
	await get_tree().create_timer(0.5).timeout
	$Sprite3D.hide()
