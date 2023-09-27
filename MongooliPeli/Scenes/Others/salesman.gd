extends CharacterBody3D
class_name Salesman

var player = null
var state_machine
var shop_is_open
var wavenow = false
@export var player_path := "/root/level1/Mannekiini"
@onready var anim_tree = $AnimationTree
@onready var laughaudio = $AudioStreamPlayer3D
@onready var coinaudio = $AudioStreamPlayer3D2
var audioflag = true

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func shop_open(open):#saa pelaajan physprossista tiedon
	if open:
		shop_is_open = true
	if not open:
		shop_is_open = false
		audioflag = true


func item_bought():
	coinaudio.play()
	
func shop_was_closed():#anim wave funktio
	wavenow = true
	await get_tree().create_timer(1).timeout
	wavenow = false
	
func _process(delta):
	
	if shop_is_open and audioflag == true:
		laughaudio.play()
		var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(kohta,Vector3.UP,true)
		audioflag = false
	#pass
		# Conditions
	
	anim_tree.set("parameters/conditions/idle", !shop_is_open)

	anim_tree.set("parameters/conditions/wave", wavenow) 

	anim_tree.set("parameters/conditions/shopping", shop_is_open)



	match state_machine.get_current_node():
#		"Idle":
#
#				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
#				var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
#				look_at(kohta,Vector3.UP,true)
#				var direction = global_position.direction_to(player.global_position)
#				velocity = direction * 3
#				move_and_slide()
		"Wave":

			var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(kohta,Vector3.UP,true)
			
		"GreedyIdle":
			pass
