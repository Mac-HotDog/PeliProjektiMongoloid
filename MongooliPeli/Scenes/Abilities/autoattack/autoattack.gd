extends Node3D
#spawner


#var range = 10
#var speed = 30
#var direction = Vector3.ZERO
var instance = preload("res://Scenes/Abilities/autoattack/autoattackprojectile.tscn")
var autoattackprojectile

@export var player_path := "/root/level1/Mannekiini"
@export var marker_path := "/root/level1/Mannekiini/Marker3D"

@onready var player = get_node(player_path)
@onready var marker = get_node(marker_path)

var target_pos
var target
var ready_to_execute
var aa_free = false
var laskuri = 0
var delay = 0.3

func _ready():
	pass
	#get_parent()
#	# Set the initial position and rotation
#	global_transform.origin = player.global_transform.origin
#	global_transform.basis = player.global_transform.basis

func attack_target_position(pos):
	target_pos = pos
	#return target

func target_getter(kohde):# estää aa despawn jos väliin tulee vihu ja aa osuu siihe
	target = kohde

func execute(node):
	top_level = true
	aa_free = false
	#await get_tree().create_timer(delay).timeout
	autoattackprojectile = instance.instantiate()
	add_child(autoattackprojectile)
	autoattackprojectile.target_getter(target)
	#print(target)

	global_transform.origin = marker.global_transform.origin
	global_transform.basis = marker.global_transform.basis
	
	ready_to_execute = true
 
func aa_freed():
	aa_free = true
	player.aa_freed()

func _physics_process(delta):
	if ready_to_execute and aa_free == false:
		autoattackprojectile.attack_target_position(target_pos)
		#print(target_pos)



	

	#bullet.linear_velocity = Vector3(10,0,0)

	

