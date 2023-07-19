extends RigidBody3D






func _on_body_entered(body):
	if body.name == "Ground":
		queue_free()
