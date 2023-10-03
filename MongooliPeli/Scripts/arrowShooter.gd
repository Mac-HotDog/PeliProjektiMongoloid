extends Node3D


var arrow = preload("res://Scenes/level_nodes/arrow.tscn")

func shoot():
	var projectile = arrow.instantiate()
	add_child(projectile)
	#projectile.top_level = true
	projectile.linear_velocity = Vector3(0,0,10)
	

func _on_timer_timeout():
	shoot()
