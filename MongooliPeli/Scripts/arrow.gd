extends RigidBody3D



func _on_area_3d_area_entered(area):
	queue_free()
	


func _on_area_3d_body_entered(body):
	var ryhmat = body.get_groups()
	for x in ryhmat:
		if x == "player":
			queue_free()
	
