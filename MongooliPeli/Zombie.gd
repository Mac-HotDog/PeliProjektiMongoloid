extends Enemy


var player = null
var state_machine
var dead = false
var in_aoeslow = false
var last_hitter #kuka teki dmg vikana

var SPEED = 4.0
@export var ATTACK_RANGE = 2.0#enemmänkin targettaus range
@export var dmg_number_scene = preload("res://Scenes/Others/dmg_number.tscn")
var dmg_number
@export var player_path := "/root/level1/Mannekiini"
@export var gold_value = 15

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
#@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
#@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var bar = $Resourcebar
@onready var deathaudio = $audiodeath
@onready var impactaudio = $audioimpact


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
func change_health(value):
	dmg_number = dmg_number_scene.instantiate()
	add_child(dmg_number)#sqpawnaa ja deletoid koko ajan, vie varmaa tehoja
	dmg_number.add_dmg_numbers(str(value), self.global_position,1,1)
	health += value
	
#add_dmg_numbers()

func whendead():
	dmg_number.queue_free()
	last_hitter.change_gold(gold_value)
	#last_hitter.target_killed()
	dead = true
	deathaudio.play()
	$CollisionShape3D.disabled = true
	$Area3DZombie/CollisionShape3D2.disabled = true
	bar.visible = false
	#manaBar.visible = false
	await get_tree().create_timer(5).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	if bar:
		bar.global_position = self.global_position
		bar.global_position[1] = 3.5
		bar.update_bar(health)
#	if manaBar:
#		manaBar.update_bar(mana)

	if die() and dead == false:
		whendead()
		
	match state_machine.get_current_node():
		#"GetUp":
			#look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"Run":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	anim_tree.set("parameters/conditions/die", die())
	
	move_and_slide()


func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE


func _hit_finished():#jos on 
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 0.5:
		#var dir = global_position.direction_to(player.global_position)#tutoriaalista
		player.hit(true)
		

func take_dot():
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	
func _on_area_3d_zombie_area_entered(area):#dmg alueiden classit vaihdettu
	#koitin tehdä koodista järkevämpää, ei toimi vielä
	var area_source = area.get_parent()
	var spawner_source = area_source.get_parent()
#	var dmg_source = area_source.name_returner()
#	health += -player.dmg_returner(dmg_source)

	if spawner_source.get_parent() is Entity:
		last_hitter = spawner_source.get_parent()
	if area is autoattack or area.get_parent() is autoattack:
		impactaudio.play()
		change_health(-player.aa_dmg_returner())
	if area is bullet or area.get_parent() is bullet:
		change_health(-player.bullet_dmg_returner())
		#print(area.class)
	if area is aoeslow or area.get_parent() is aoeslow:  
		take_dot()
		SPEED = 1


func _on_area_3d_zombie_area_exited(area):
	if area is aoeslow:
		in_aoeslow = false
		SPEED = 4
