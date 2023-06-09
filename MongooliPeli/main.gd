extends Node3D




func _on_static_body_3d_input_event(camera, event, position2, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("neekeri")
		$Marker.transform.origin = position2
		$Player.target = position2
