extends Node3D




func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:         
			$Marker.visible = true         
			$Marker.transform.origin = position
			$Player.target = position         
			await get_tree().create_timer(1).timeout         
			$Marker.visible = false
