extends RigidBody3D



var speed = 10.0
var gravity = 0
var parent = get_parent()
var target


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

func attack_target(pos):
	target = pos

func _physics_process(delta):


	
	top_level = true
	var direction = global_position.direction_to(target)
	var too = Vector3(direction[0], 1,direction[2])
	var to = Vector3(target[0], 1.5,target[2])
	var movement = too * speed * delta
	transform.origin[0] += movement[0]
	transform.origin[1] = 1.5
	transform.origin[2] += movement[2]
	
	
#	position[0] += movement[0]
#	position[1] = 1
#	position[2] += movement[2]

	#print(position)
	
	
#	var target_direction = (target - position).normalized()
#	var velocity = target_direction * speed
#	move_and_collide(velocity * delta)
	
	
	#move_toward(self.position, target, speed)
	#if self.collide == true:
		#queue_free()

		
	# eri tavat
	#var direction Vector3()
#	var forward_vector = global_transform.basis.z.normalized()
#	var velocity = forward_vector * speed
	#var velocity = mouse_pos * speed
	#apply_central_impulse(velocity)
	
	#move_and_collide(velocity)
	
	#linear_velocity = Vector3(10,0,0)


#Area3D:<Area3D#45030049371>




func _on_area_3d_area_entered(area):
	var player_area := Area3D#45030049371    #?????
	if area:
#		print(area)
		#if area != player_area:
		queue_free()
