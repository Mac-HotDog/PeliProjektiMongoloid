extends Enemy
#vissiin vaan tällä toimii hp regen toistaseks

var player = null
var player_pos #viiveellinen pelaajn sijainti
#var allow_getting_pos = false #lippu pelaaja posille
var timer
var dead = false
var last_hitter #kuka teki dmg vikana
var SPEED = 4.0
var ATTACK_RANGE = 9.0
@export var gold_value = 200
@export var exp_value = 80

#@export var player_path : NodePath
@export var player_path := "/root/level1/Mannekiini"
@onready var nav_agent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var bar = $Resourcebar
@onready var dash_timer = $TimerDash
@export var dmg_number_scene = preload("res://Scenes/Others/dmg_number.tscn")
var dmg_number
@onready var impactaudio = $audioimpact
@onready var deathaudio = $audiodeath

var allow_idle
var casting_animation = ["powerup","ultimate","jump","jumpdown"]
#abilities


#func cast_spear():
#	if spear_timer.time_left < 0.1:
#		spear_timer.start(spear_cd)


# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.set_speed_scale(2)
	player = get_node(player_path)
	anim_player.play("jumpdown")
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.timeout.connect(_on_timer_timeout)

func play_animation(animation,condition):
	if condition:
		if animation == "run":
			allow_idle = false
			anim_player.set_speed_scale(2)
			anim_player.play(animation)
		if animation == "death":
			allow_idle = false
			anim_player.set_speed_scale(2)
			anim_player.play(animation)
			
func whendead():
	dead = true
	play_animation("death",true)
	last_hitter.change_gold(gold_value)
	last_hitter.change_exp(exp_value)
	#last_hitter.target_killed()
	deathaudio.play()
	$Area3D/CollisionShape3D.disabled = true
	bar.visible = false
	await get_tree().create_timer(5).timeout
	queue_free()

func change_health(value):
	dmg_number = dmg_number_scene.instantiate()
	add_child(dmg_number)#sqpawnaa ja deletoid koko ajan, vie varmaa tehoja
	dmg_number.add_dmg_numbers(str(value), self.global_position,1,1)
	health += value
	
func gold_value_returner():
	return gold_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	

#
	if bar:
		bar.global_position = self.global_position
		bar.global_position[1] = 3.5
		bar.update_bar(health)

		
	velocity = Vector3.ZERO#?
	
	if die() == true and dead == false:
		whendead()
	
	if _target_not_in_range():
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(kohta,Vector3.UP,true)
		play_animation("run",true)
	
	if _target_in_range():
		pass
	
	allow_run = not navigationAgent.is_navigation_finished()
	activeanimationplaying = activeanimations.has(animplaying)

	move_and_slide()
	
#animaatioiden takistus funtiot
func _target_in_range():
	var x = global_position.distance_to(player.global_position) < ATTACK_RANGE
	return x
	
func _target_not_in_range():
	var x = global_position.distance_to(player.global_position) > ATTACK_RANGE
	return x
	
#func allow_getting_pos():
#	pass


#tällä saadaan melee osumisen tieto
#func _hit_finished():
#	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 0.5:
#		#var dir = global_position.direction_to(player.global_position)
#		var melee = true
#		player.hit(melee)

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


func _on_area_3d_area_entered(area):
#	if area:
#		#health += -15
#		timer.start()
#		#print(area)
#		change_health(-15)
	var area_source = area.get_parent()
	var spawner_source = area_source.get_parent()
	if spawner_source.get_parent() is Entity:
		last_hitter = spawner_source.get_parent()
	if area is autoattack or area.get_parent() is autoattack:
		impactaudio.play()
		change_health(-player.aa_dmg_returner())
	if area is bullet or area.get_parent() is bullet:
		change_health(-player.bullet_dmg_returner())
		#print(area.class)
	if area is aoeslow:
		take_dot()
		SPEED = 2
		

func _on_area_3d_area_exited(area):
	timer.stop()
	if area is aoeslow:
		SPEED = 4
	
func _on_timer_timeout():
	health += -5

