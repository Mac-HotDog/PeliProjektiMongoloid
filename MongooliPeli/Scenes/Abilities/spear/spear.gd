extends Node3D


var spearprojectile = preload("res://Scenes/Abilities/spear/spearprojectile.tscn")


@onready var parent = get_parent()
@export var marker_path := "/root/Main/guard/Marker3D"
@onready var marker = get_node(marker_path)
var target_pos

func target_position(pos):
	target_pos = pos

func execute(node):
	top_level = true
	var spear = spearprojectile.instantiate()
	spear.target_position(target_pos)
	#projectile.transform.origin = marker.global_position
	add_child(spear)
	global_transform.origin = marker.global_transform.origin
	global_transform.basis = marker.global_transform.basis

	#projectile.linear_velocity = Vector3(10,0,0)



#func _physics_process(delta):
#	top_level = true
#	var projectile = fireballprojectile.instantiate()
#	projectile.transform.origin = parent.position
#	projectile.linear_velocity = Vector3(10,0,0)
	
