extends Node3D

var ball = preload("res://Scenes/Abilities/acidBall/acidBallProjectile.tscn")
var splat =preload("res://Scenes/Abilities/acidBall/acidsplat.tscn")
var splat2
var ball2
var timer
#vittuvittuvittuvittuvittuvittuvittu
func _ready():
	
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(2.0)  # set the wait time to 5 seconds
	timer.set_one_shot(true)  # make it a one-shot timer
	#putkipommi
	timer.timeout.connect(_on_timer_timeout)

func execute(node):
	top_level = true
	ball2 = ball.instantiate()
	ball2.linear_velocity = Vector3(10, 1, 0)
	add_child(ball2)
	
	timer.start()  # start the timer

func _on_timer_timeout():
	if ball2:
		ball2.queue_free()  # delete the child node
		top_level = true
		
		add_child(splat.instantiate())
