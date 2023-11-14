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
var spawnpoint

func _ready():
	pass



func execute(node):
	#await get_tree().create_timer(0.1).timeout
	var xx = player.transform.basis.z
	spawnpoint = player.global_position + xx
	spawnpoint[1] += 0.5
	top_level = true
	stomp = instance.instantiate()
	add_child(stomp)
	stomp.get_player(get_parent())


	stomp.global_position = spawnpoint
	await get_tree().create_timer(1.5).timeout
	stomp.reset_area()
	stomp.queue_free()


