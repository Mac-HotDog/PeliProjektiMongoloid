extends RigidBody3D
class_name autoattack


var speed = 10.0
var gravity = 0
@onready var parent = get_parent()
var target_pos
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
func name_returner(): #turha
	return "autoattack"
	
func target_getter(kohde):# estää aa despawn jos väliin tulee vihu ja aa osuu siihe
	target = kohde
	
func attack_target_position(pos):
	target_pos = pos

func _physics_process(delta):
	top_level = true
	if target_pos != null:

		#print(target_pos)
		var direction = global_position.direction_to(target_pos)
		var too = Vector3(direction[0], 1.5,direction[2])
		var to = Vector3(target_pos[0], 1.5,target_pos[2])
		var movement = too * speed * delta
		transform.origin[0] += movement[0]
		transform.origin[1] = 1.5
		transform.origin[2] += movement[2]
	if target == null:
		queue_free()
	
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
	if area.get_parent() is Enemy:
		#print(target)
		if area.get_parent() == target or area == target:
			parent.aa_freed()
			queue_free()
