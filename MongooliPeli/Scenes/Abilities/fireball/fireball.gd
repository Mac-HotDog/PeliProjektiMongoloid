extends Node3D

var fireballprojectile = preload("res://Scenes/Abilities/fireball/fireballprojectile.tscn")

func execute(node):
	var mouse_pos = get_viewport().get_mouse_position()
	var projectile = fireballprojectile.instantiate()
	add_child(projectile)
	projectile.linear_velocity = Vector3(10,0,0)
	
