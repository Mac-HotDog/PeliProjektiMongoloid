extends Node3D



#var range = 10
#var speed = 30
#var direction = Vector3.ZERO
var instance = preload("res://Scenes/Abilities/bullet/bulletprojectile.tscn")


@export var player_path := "/root/level1/Mannekiini"
@export var marker_path := "/root/level1/Mannekiini/Marker3D"

@onready var player = get_node(player_path)
@onready var marker = get_node(marker_path)
var mouse_pos
var laskuri = 0

func _ready():
	#get_parent()
	pass
#	# Set the initial position and rotation
#	global_transform.origin = player.global_transform.origin
#	global_transform.basis = player.global_transform.basis
func mouse_position(pos):
	mouse_pos = pos
	return mouse_pos

	
	


func execute(node):
	await get_tree().create_timer(0.1).timeout
	top_level = true
	var bullet = instance.instantiate()
	bullet.mouse_position(mouse_pos)
	add_child(bullet)
	global_transform.origin = marker.global_transform.origin
	global_transform.basis = marker.global_transform.basis
 


	

	#bullet.linear_velocity = Vector3(10,0,0)

	

