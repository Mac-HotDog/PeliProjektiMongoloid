extends Enemy


var player = null
var state_machine
var timer
var dead = false
var SPEED = 4.0
const ATTACK_RANGE = 8.0

#@export var player_path : NodePath
@export var player_path := "/root/level1/Mannekiini"
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var spear_timer = $TimerSpear
@onready var right_hand = $"Armature/Skeleton3D/Physical Bone mixamorig_RightHand"#turha?
@onready var spearmesh = $SpearMesh#turha?
@onready var skeleton = $Armature/Skeleton3D#turha?
@onready var impactaudio = $audioimpact
#abilities
var spear = load_ability("spear")
var spear_cd = 4.0

#func cast_spear():
#	if spear_timer.time_left < 0.1:
#		spear_timer.start(spear_cd)

func whendead():
	dead = true
	#deathaudio.play()
	$HealthBar3D.visible = false
	$ManaBar3D.visible = false
	$Area3D/CollisionShape3D.disabled = true
	#anim_tree.set("parameters/conditions/death",true)
	await get_tree().create_timer(5).timeout
	queue_free()
	#manaBar.visible = false


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.timeout.connect(_on_timer_timeout)
	var right_hand_bone_index = skeleton.get_bone_name(22)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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

	if bar:
		bar.update_bar(health)
	if manaBar:
		manaBar.update_bar(mana)

		
	velocity = Vector3.ZERO#?
	
		# Conditions
	anim_tree.set("parameters/conditions/death",die())
	if die() == true and dead == false:
		whendead()
	
	anim_tree.set("parameters/conditions/throw", allow_cast_spear())

	anim_tree.set("parameters/conditions/run", _target_not_in_range())
	
	anim_tree.set("parameters/conditions/idle", allow_idle())

	
	
	match state_machine.get_current_node():
		"Run":
			# Navigation
			if die():
				return
			if _target_not_in_range():
				#print(self.global_rotation)
					
				nav_agent.set_target_position(player.global_transform.origin)
				#nav_agent.set_path_desired_distance(ATTACK_RANGE)# kusee pathingia, tarvii paremman
				#print(nav_agent.distance_to_target())
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			
				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
				var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
				look_at(kohta,Vector3.UP,true)
		"Throw":
			if die():
				return
			var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			look_at(kohta,Vector3.UP,true)

			#cast_spear()
			

			


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
	
func allow_cast_spear():
	var in_range = global_position.distance_to(player.global_position) < ATTACK_RANGE
	if in_range and spear_timer.time_left < 0.1:
		return true
	else:
		return false
		
func allow_idle():
		if _target_in_range():
			return true
		else:
			return false
			
func throw_moment():
	#if spear_timer.time_left < 0.1: ##hojojoo timer alkaa ina alu
	spear_timer.start(spear_cd)
	spear.target_position(player.position)
	spear.execute(self)

#tällä saadaan melee osumisen tieto
#func _hit_finished():
#	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 0.5:
#		#var dir = global_position.direction_to(player.global_position)
#		var melee = true
#		player.hit(melee)

func take_dot():
	await get_tree().create_timer(0.5).timeout
	health += -player.aoeslow_dmg_returner()
	await get_tree().create_timer(0.5).timeout
	health += -player.aoeslow_dmg_returner()
	await get_tree().create_timer(0.5).timeout
	health += -player.aoeslow_dmg_returner()
	await get_tree().create_timer(0.5).timeout
	health += -player.aoeslow_dmg_returner()
	await get_tree().create_timer(0.5).timeout
	health += -player.aoeslow_dmg_returner()
	await get_tree().create_timer(0.5).timeout
	health += -player.aoeslow_dmg_returner()
	await get_tree().create_timer(0.5).timeout
	health += -player.aoeslow_dmg_returner()
	await get_tree().create_timer(0.5).timeout
	health += -player.aoeslow_dmg_returner()


func _on_area_3d_area_entered(area):
#	if area:
#		#health += -15
#		timer.start()
#		#print(area)
#		change_health(-15)
	if area is autoattack:
		impactaudio.play()
		health += -player.aa_dmg_returner()
	if area is bullet:
		health += -player.bullet_dmg_returner()
	if area is aoeslow:
		take_dot()
		SPEED = 1
		

func _on_area_3d_area_exited(area):
	timer.stop()
	if area is aoeslow:
		SPEED = 4
	
func _on_timer_timeout():
	health += -5
