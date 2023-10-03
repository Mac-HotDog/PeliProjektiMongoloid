extends Enemy
#vissiin vaan tällä toimii hp regen toistaseks

var player = null
var player_pos #viiveellinen pelaajn sijainti
#var allow_getting_pos = false #lippu pelaaja posille
var state_machine
var timer
var dead = false
var last_hitter #kuka teki dmg vikana
var SPEED = 4.0
var ATTACK_RANGE = 9.0
@export var gold_value = 10
@export var exp_value = 10

#@export var player_path : NodePath
@export var player_path := "/root/level1/Mannekiini"
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
#@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
#@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var bar = $Resourcebar
@onready var spear_timer = $TimerSpear
@export var dmg_number_scene = preload("res://Scenes/Others/dmg_number.tscn")
var dmg_number
@onready var impactaudio = $audioimpact
@onready var deathaudio = $audiodeath
#abilities
var spear = load_ability("spear")
var spear_cd = 4.0

#func cast_spear():
#	if spear_timer.time_left < 0.1:
#		spear_timer.start(spear_cd)


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.timeout.connect(_on_timer_timeout)
	
func whendead():
	dead = true
	last_hitter.change_gold(gold_value)
	last_hitter.change_exp(exp_value)
	#last_hitter.target_killed()
	deathaudio.play()
	#deathaudio.play()
	#$HealthBar3D.visible = false
	#$ManaBar3D.visible = false
	$Area3D/CollisionShape3D.disabled = true
	bar.visible = false
	await get_tree().create_timer(5).timeout
	queue_free()
	#manaBar.visible = false

	
func change_health(value):
	dmg_number = dmg_number_scene.instantiate()
	add_child(dmg_number)#sqpawnaa ja deletoid koko ajan, vie varmaa tehoja
	dmg_number.add_dmg_numbers(str(value), self.global_position,1,1)
	health += value
	
func gold_value_returner():
	return gold_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#turhaa paskaa mitä en saanu toimii
#	var vittu = $Armature/Skeleton3D.global_transform * $Armature/Skeleton3D.get_bone_global_pose(22)
#	var perse = $Armature/Skeleton3D.get_bone_global_pose(22)
#	var saatana = $Armature/Skeleton3D.get_bone_pose(22)
#	#spearmesh.set_transform(perse)
#	#spearmesh.top_level = true
#	#spearmesh.global_transform.origin = right_hand.global_transform.origin
#	#spearmesh.set_global_transform(saatana)
#	var skeleton_global_transform = skeleton.get_global_transform()
#	var right_hand_local_transform = skeleton.get_bone_pose(22)
#	var right_hand_global_transform = (skeleton_global_transform * right_hand_local_transform)

	#spearmesh.transform = right_hand_local_transform
	#print(right_hand_local_transform.origin)
	#print(nav_agent.is_target_reached())
#
	if bar:
		bar.global_position = self.global_position
		bar.global_position[1] = 3.5
		bar.update_bar(health)
#	if manaBar:
#		manaBar.update_bar(mana)

		
	velocity = Vector3.ZERO#?
	
		# Conditions
	anim_tree.set("parameters/conditions/death",die())
	if die() == true and dead == false:
		whendead()

	
	anim_tree.set("parameters/conditions/throw", allow_cast_spear())
	anim_tree.set("parameters/conditions/death", die())
	anim_tree.set("parameters/conditions/run", _target_not_in_range())
	
	anim_tree.set("parameters/conditions/idle", allow_idle())

	
	
	match state_machine.get_current_node():
		"Run":
			# Navigation
			await get_tree().create_timer(0.2).timeout
			if _target_not_in_range():
				#print(self.global_rotation)
					
				nav_agent.set_target_position(player.global_position)#transform.origin)
				#nav_agent.set_path_desired_distance(ATTACK_RANGE)# kusee pathingia, tarvii paremman
				#print(nav_agent.distance_to_target())
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			
				rotation.y = lerp_angle(rotation.y, atan2(velocity.x, + velocity.z), delta * 10.0)
				var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
				#look_at(kohta,Vector3.UP,true)
#				var direction = global_position.direction_to(player.global_position)
#				velocity = direction * 3
#				move_and_slide()
		"Throw":
			if die():
				return
#			var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
#			look_at(kohta,Vector3.UP,true)


			#cast_spear()
			
		"Idle":
			spear.target_position(player.position)#pelaajan on helppo väistää keihäs jos tämä on idlessä
			var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(kohta,Vector3.UP,true)
			#rotation.y = lerp_angle(rotation.y, -player.global_position.z, delta * 10.0)
		
		"Death":
			pass


#	print("nav " , nav_agent.is_navigation_finished())
#	print("reachable ", nav_agent.is_target_reachable())
#	print("Current animation: ", state_machine.get_current_node())
#	print("Throw parameter: ", anim_tree.get("parameters/conditions/throw"))
#	print("Idle parameter: ", anim_tree.get("parameters/conditions/idle"))
#	print("Run parameter: ", anim_tree.get("parameters/conditions/run"))
#	print("Player: ", player)
	
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
	
func allow_cast_spear():
	var in_range = global_position.distance_to(player.global_position) < ATTACK_RANGE
	if in_range and spear_timer.time_left < 0.1 and not die():
		return true
	else:
		return false
		
func allow_idle():
		if _target_in_range() and not die():
			return true
		else:
			return false
			
func throw_moment():
	#if spear_timer.time_left < 0.1: ##hojojoo timer alkaa ina alu
	spear_timer.start(spear_cd)
	#spear.target_position(player.position)
	spear.execute(self)

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
		SPEED = 1
		

func _on_area_3d_area_exited(area):
	timer.stop()
	if area is aoeslow:
		SPEED = 4
	
func _on_timer_timeout():
	health += -5
