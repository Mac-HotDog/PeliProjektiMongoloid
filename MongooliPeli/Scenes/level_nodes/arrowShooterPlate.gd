extends Node3D

@export var some_node: Node3D

var arrow = preload("res://Scenes/level_nodes/arrow.tscn")



func _on_area_3d_body_entered(body):
	#print("vittan")
	await get_tree().create_timer(1).timeout
	$AudioStreamPlayer3D.play()
	#await get_tree().create_timer(startDelay).timeout
	var projectile = arrow.instantiate()
	add_child(projectile)
	#projectile.top_level = true
	var direction_to_marker = $Marker3D.global_transform.origin - projectile.global_transform.origin
	var velocity = direction_to_marker.normalized() * 10
	projectile.linear_velocity = velocity
