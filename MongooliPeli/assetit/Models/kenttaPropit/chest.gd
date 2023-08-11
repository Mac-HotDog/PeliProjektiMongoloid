extends Node3D


func _on_area_3d_body_entered(body):
	if body and body.is_in_group("Ground") != true:
		queue_free()
