extends Node3D


func _on_area_3d_body_entered(body):
	if body.get_groups().size() > 0:
		if "player" == body.get_groups()[0]:
			get_tree().change_scene_to_file("res://Scenes/Levels/VoititPelinScene.tscn")
