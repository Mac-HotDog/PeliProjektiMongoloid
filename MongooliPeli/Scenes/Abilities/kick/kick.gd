extends Node3D




var instance = preload("res://Scenes/Abilities/kick/kickarea.tscn")


@export var player_path := "/root/level1/Mannekiini"
@export var marker_path := "/root/level1/Mannekiini/Marker3D"

@onready var player = get_node(player_path)
@onready var marker = get_node(marker_path)
var mouse_pos
var kick

func _ready():
	#get_parent()
	pass
#	# Set the initial position and rotation
#	global_transform.origin = player.global_transform.origin
#	global_transform.basis = player.global_transform.basis
func mouse_position(pos):
	mouse_pos = pos
	return mouse_pos

	
func remove_area():
	kick.disable_area()


func execute(node):
	#await get_tree().create_timer(0.1).timeout
	top_level = true
	kick = instance.instantiate()
	#kick.mouse_position(mouse_pos)
	add_child(kick)
	kick.global_transform.basis = player.global_transform.basis
	#kick.global_transform.origin = player.global_transform.origin
	kick.global_position = player.global_position
	#kick.global_position[2] = player.global_position[2] - 1
	await get_tree().create_timer(1).timeout
	kick.queue_free()

	

	#bullet.linear_velocity = Vector3(10,0,0)

	
