extends Enemy


var player = null
var state_machine
var dead = false
var in_aoeslow = false

var SPEED = 4.0
const ATTACK_RANGE = 2.0

@export var player_path := "/root/level1/Mannekiini"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var deathaudio = $audiodeath
@onready var impactaudio = $audioimpact


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
func change_health(value):
	health += value
	


func whendead():
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
		bar.update_bar(health)
#	if manaBar:
#		manaBar.update_bar(mana)

	if die() and dead == false:
		whendead()
		
	match state_machine.get_current_node():
		"GetUp":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
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


func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)
		

func take_dot():
	if in_aoeslow:
		await get_tree().create_timer(0.5).timeout
		health += -player.aoeslow_dmg_returner()
	if in_aoeslow:
		await get_tree().create_timer(0.5).timeout
		health += -player.aoeslow_dmg_returner()
	if in_aoeslow:
		await get_tree().create_timer(0.5).timeout
		health += -player.aoeslow_dmg_returner()
	if in_aoeslow:
		await get_tree().create_timer(0.5).timeout
		health += -player.aoeslow_dmg_returner()
	if in_aoeslow:
		await get_tree().create_timer(0.5).timeout
		health += -player.aoeslow_dmg_returner()
	if in_aoeslow:
		await get_tree().create_timer(0.5).timeout
		health += -player.aoeslow_dmg_returner()
	if in_aoeslow:
		await get_tree().create_timer(0.5).timeout
		health += -player.aoeslow_dmg_returner()
	if in_aoeslow:
		await get_tree().create_timer(0.5).timeout
		health += -player.aoeslow_dmg_returner()



func _on_area_3d_zombie_area_entered(area):#dmg alueiden classit vaihdettu
	if area is autoattack:
		impactaudio.play()
		health += -player.aa_dmg_returner()
	if area is bullet:
		health += -player.bullet_dmg_returner()
	if area is aoeslow:
		in_aoeslow = true
		take_dot()
		SPEED = 1


func _on_area_3d_zombie_area_exited(area):
	if area is aoeslow:
		in_aoeslow = false
		SPEED = 4
