extends Node3D



#var range = 10
#var speed = 30
#var direction = Vector3.ZERO
var instance = preload("res://Scenes/Abilities/groundstomp/groundstomparea.tscn")


@export var player_path := "/root/level1/Mannekiini"
@export var marker_path := "/root/level1/Mannekiini/Marker3D"

@onready var player = get_node(player_path)
@onready var parent = get_parent()
var marker
var stomp

func _ready():
	pass


func execute(node):
	#await get_tree().create_timer(0.1).timeout
	top_level = true
	stomp = instance.instantiate()
	#bullet.mouse_position(mouse_pos)
	add_child(stomp)
	stomp.global_position = player.global_position
	#flame.global_transform.origin = marker.global_transform.origin
	#flame.global_transform.basis = marker.global_transform.basis
