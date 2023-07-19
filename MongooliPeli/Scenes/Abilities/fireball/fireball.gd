extends Node3D


var fireballprojectile = preload("res://Scenes/Abilities/fireball/fireballprojectile.tscn")


@onready var parent = get_parent()
@export var marker_path := "/root/Main/Player/Marker3D"


func execute(node):
	top_level = true
	var mouse_pos = get_viewport().get_mouse_position()
	var projectile = fireballprojectile.instantiate()
	#var marker = get_node(marker_path)
	#projectile.transform.origin = marker.global_position
	add_child(projectile)

	projectile.linear_velocity = Vector3(10,0,0)



#func _physics_process(delta):
#	top_level = true
#	var projectile = fireballprojectile.instantiate()
#	projectile.transform.origin = parent.position
#	projectile.linear_velocity = Vector3(10,0,0)
	
