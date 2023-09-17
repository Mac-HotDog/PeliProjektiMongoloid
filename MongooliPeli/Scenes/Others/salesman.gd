extends CharacterBody3D
class_name Salesman

var player = null
var state_machine
@export var player_path := "/root/level1/Mannekiini"
@onready var anim_tree = $AnimationTree

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func _process(delta):

	pass
		# Conditions
	
#	anim_tree.set("parameters/conditions/idle",)
#
#	anim_tree.set("parameters/conditions/wave", )
#
#	anim_tree.set("parameters/conditions/shopping",)

	
	
#	match state_machine.get_current_node():
#		"Idle":
#
#				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
#				var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
#				look_at(kohta,Vector3.UP,true)
##				var direction = global_position.direction_to(player.global_position)
##				velocity = direction * 3
##				move_and_slide()
#		"Wave":
#
#			var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
#			look_at(kohta,Vector3.UP,true)
