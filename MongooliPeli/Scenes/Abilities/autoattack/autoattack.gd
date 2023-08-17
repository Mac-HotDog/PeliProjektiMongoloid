extends Node3D



#var range = 10
#var speed = 30
#var direction = Vector3.ZERO
var instance = preload("res://Scenes/Abilities/autoattack/autoattackprojectile.tscn")


@export var player_path := "/root/level1/Mannekiini"
@export var marker_path := "/root/level1/Mannekiini/Marker3D"

@onready var player = get_node(player_path)
@onready var marker = get_node(marker_path)
var target
var laskuri = 0
var delay = 0.3

func _ready():
	#get_parent()
	pass
#	# Set the initial position and rotation
#	global_transform.origin = player.global_transform.origin
#	global_transform.basis = player.global_transform.basis
func attack_target(pos):
	target = pos
	#return target

	
	


func execute(node):
	top_level = true
	await get_tree().create_timer(delay).timeout
	var autoattack = instance.instantiate()
	add_child(autoattack)
	autoattack.attack_target(target)
	global_transform.origin = marker.global_transform.origin
	global_transform.basis = marker.global_transform.basis
 


	

	#bullet.linear_velocity = Vector3(10,0,0)

	

