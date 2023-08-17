extends RigidBody3D
#
#
var target_pos
var speed = 3
var gravity = 0
var timer
var parent = get_parent()
var despawn_distance = 20
@onready var initial_position = position
#
##func _ready():
##	timer = Timer.new()  # create a new Timer
##	add_child(timer)  # add it as a child
##	timer.set_wait_time(2.0)  # set the wait time to 5 seconds
##	#timer.set_one_shot(true)  # make it a one-shot timer
##	#putkipommi
##	timer.timeout.connect(_on_timer_timeout)
##	timer.start()
##
##func _on_timer_timeout():
##	self.queue_free()
##
#	#enemmäkin suunta
#func mouse_position(pos):
#	mouse_pos = pos

func target_position(pos):
	target_pos = pos

func _physics_process(delta):
	top_level = true

	#var to = global_position.direction_to(target_pos)
	#var to = Vector3(target_pos[0], 1,target_pos[2])
#	var movement = to * speed * delta
#	transform.origin[0] = transform.origin[0] + movement[0]
#	transform.origin[1] = 1
#	transform.origin[2] = transform.origin[2] + movement[2]
#	var displacement = position - initial_position
#	var traveled_distance = displacement.length()
#	if traveled_distance >= despawn_distance:
#		queue_free()

	#print(position)


#	if self.collide == true:
#		queue_free()


#	# eri tavat
	var forward_vector = global_position.direction_to(target_pos)
	var velocity = forward_vector * speed
	apply_central_impulse(velocity)
	var displacement = position - initial_position
	var traveled_distance = displacement.length()

	if traveled_distance >= despawn_distance:
		queue_free()
#
#	move_and_collide(velocity)
#
#	#linear_velocity = Vector3(10,0,0)
#
#
#
#



func _on_area_3d_area_entered(area):
	if area:
		#print(area)
		queue_free()


func _on_area_3_dspearprojectile_body_entered(body):
	queue_free()
