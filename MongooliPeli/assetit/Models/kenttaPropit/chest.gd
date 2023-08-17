extends Node3D


func _on_area_3d_body_entered(body):
	if body:
		
		var ryhmat = body.get_groups()
		for x in ryhmat:
			if "player" == x:
				queue_free()
				
