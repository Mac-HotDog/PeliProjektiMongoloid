extends RigidBody3D
class_name Spear
#
var target_pos
var speed = 2
var gravity = 0
var timer
var parent = get_parent()
var despawn_distance = 25
var forward_vector
@onready var initial_position = global_position
#
func _ready():
	pass
	#self.global_transform.basis = target_pos-self.global_position
	

func target_position(pos):
	target_pos = pos

func _physics_process(delta):
	top_level = true

#	var to = global_position.direction_to(target_pos)
#	#var to = Vector3(target_pos[0], 1,target_pos[2])
#	var movement = to * speed * delta
#	transform.origin[0] += transform.origin[0] + movement[0]
#	transform.origin[1] += 1
#	transform.origin[2] += transform.origin[2] + movement[2]
#	var displacement = position - initial_position
#	var traveled_distance = displacement.length()
#	if traveled_distance >= despawn_distance:
#		queue_free()

	#print(position)


#	if self.collide == true:
#		queue_free()


	# eri tavat
	#print(position)
	forward_vector = global_position.direction_to(target_pos)
	#forward_vector[1] = 1
	var velocity = forward_vector * speed * 1.3
	apply_central_impulse(velocity)# ei tarkoitettu phys prosessiin
	#apply_central_force
	var displacement = global_position - initial_position
	var traveled_distance = displacement.length()

	if traveled_distance >= despawn_distance:
		queue_free()
	if global_position.y <= 0.7:
		queue_free()
#
#	move_and_collide(velocity)
#
#	#linear_velocity = Vector3(10,0,0)
#
#
#


func _on_area_3d_area_entered(area):
	if area is Entity: #or area.get_parent() is Entity:
		#print(area)
		queue_free()


#func _on_area_3_dspearprojectile_body_entered(body):#despanwaa jos osuu bodyyn
#	print(body)
#	queue_free()
