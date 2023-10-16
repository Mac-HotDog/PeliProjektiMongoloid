extends Node3D



#var range = 10
#var speed = 30
#var direction = Vector3.ZERO
var instance = preload("res://Scenes/Abilities/flame/flamearea.tscn")


@export var player_path := "/root/level1/Mannekiini"


@onready var parent = get_parent()

var marker
var flame

func _ready():
	#get_parent()
	pass
#	# Set the initial position and rotation
#	global_transform.origin = player.global_transform.origin
#	global_transform.basis = player.global_transform.basis


func marker_position(node):
	marker = node
	#return mouse_pos

func end_flame():
	if flame != null:
		flame.queue_free()


func execute(node):
	await get_tree().create_timer(0.1).timeout
	top_level = true
	flame = instance.instantiate()
	add_child(flame)

	flame.global_rotation = marker.global_rotation
	flame.global_position = marker.global_position
	
#	flame.global_position[1] = 2
#	flame.global_position[2] = parent.global_position[2] - 1
	
	
#	global_transform.origin = marker.global_transform.origin
#	global_transform.basis = marker.global_transform.basis
 


	

	#bullet.linear_velocity = Vector3(10,0,0)

	

