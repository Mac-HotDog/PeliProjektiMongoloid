extends RigidBody3D


#var despawn_distance = 120
#@onready var initial_position = global_position


#func _physics_process(delta):
#	var displacement = position - initial_position
#	var traveled_distance = displacement.length()
#	#if self.collide == true:
#		#queue_free()
#	if traveled_distance >= despawn_distance:
##		print(traveled_distance)
##		print("despawn")
#		queue_free()




func _on_area_3d_body_entered(body):
	var ryhmat = body.get_groups()
	for x in ryhmat:
		if x == "player":
			queue_free()
	


func _on_timer_timeout():
	queue_free()
