extends Node3D



#var range = 10
#var speed = 30
#var direction = Vector3.ZERO
var instance = preload("res://Scenes/Abilities/flame/flamearea.tscn")


@export var player_path := "/root/level1/Mannekiini"
@export var marker_path := "/root/level1/Mannekiini/Marker3D"

@onready var player = get_node(player_path)
@onready var parent = get_parent()
var marker
var flame

func _ready():
	#get_parent()
	pass
#	# Set the initial position and rotation
#	global_transform.origin = player.global_transform.origin
#	global_transform.basis = player.global_transform.basis
func marker_getter(node):
	marker = node
	#return mouse_pos

	
func end_flame():
	if flame != null:
		flame.queue_free()


func execute(node):
	#await get_tree().create_timer(0.1).timeout
	top_level = true
	flame = instance.instantiate()
	#bullet.mouse_position(mouse_pos)
	add_child(flame)
	flame.global_position = marker.global_position
	#flame.global_transform.origin = marker.global_transform.origin
	flame.global_transform.basis = marker.global_transform.basis
