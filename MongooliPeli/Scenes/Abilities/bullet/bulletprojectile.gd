extends RigidBody3D



var speed = 4
var gravity = 0
var timer
var parent = get_parent()
var direction = Vector3(1, 0, 0)
var mouse_pos
var despawn_distance = 20
@onready var initial_position = position

#func _ready():
#	timer = Timer.new()  # create a new Timer
#	add_child(timer)  # add it as a child
#	timer.set_wait_time(2.0)  # set the wait time to 5 seconds
#	#timer.set_one_shot(true)  # make it a one-shot timer
#	#putkipommi
#	timer.timeout.connect(_on_timer_timeout)
#	timer.start()
#
#func _on_timer_timeout():
#	self.queue_free()
#
	
func mouse_position(pos):
	mouse_pos = pos

func _physics_process(delta):


	
	top_level = true

	# eri tavat
	var to = Vector3(mouse_pos[0], 1,mouse_pos[2])
	var movement = to * speed * delta
	transform.origin += movement
	var displacement = position - initial_position
	var traveled_distance = displacement.length()
	#if self.collide == true:
		#queue_free()
	if traveled_distance >= despawn_distance:
		queue_free()
		
	#var direction Vector3()
#	var forward_vector = global_transform.basis.z.normalized()
#	var velocity = forward_vector * speed
	#var velocity = mouse_pos * speed
	#apply_central_impulse(velocity)
	
	#move_and_collide(velocity)
	
	#linear_velocity = Vector3(10,0,0)




func _on_area_3d_area_entered(area):
	if area:
		queue_free()
