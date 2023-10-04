extends Entity

@export var Speed = 5
@export var gravity = 6
@export var jump_speed = 3.5
#@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
#@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var bar = $Resourcebar
@onready var navigationAgent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@export var inventoryscene = preload("res://Scenes/HUD/inventorynew.tscn")
@onready var inventory = inventoryscene.instantiate()
@onready var gold_label =$Label3DGold
@export var salesman_path := "/root/level1/salesman"
@onready var shopscene = preload("res://Scenes/HUD/shop.tscn")
@onready var shop = shopscene.instantiate()
#audio
@onready var bullet_cast_sound = $audiot/audiobulletcast
@onready var fireball_cast_sound =$audiot/audiofireballcast #nykyään lumimyrsky
@onready var death_sound = $audiot/audiodeath

#dmg numbers
var base_attack_dmg = 7
var attack_dmg = base_attack_dmg
@export var bullet_dmg = 30#returner funtiossa uusi kaava tälle
@export var autoattack_dmg = 15
@export var aoeslow_dmg = 7

#ranges
@export var aa_range = 8
@export var aoeslow_range = 15


#dashia varten..
#@onready var dash_marker = $Marker3Ddash #turha
@onready var dash_cast_sound = $audiot/audiodashcast

# aa varten
@onready var targetmeshinstance = preload("res://Scenes/HUD/redarrowsprite.tscn")
@onready var targetmesh = targetmeshinstance.instantiate()
@onready var autoattacktimer = $AutoAttackTimer # ei käytössä

# ui nodeen refrenssit
@onready var nodet =  get_node("../UI/Button2")
@onready var nodet2 =  get_node("../UI/Button3")
@onready var nodet3 =  get_node("../UI/Button4")

# havisit pelin scene
@onready var havisit =  get_node("res://Scenes/Levels/HavisitPelinScene.tscn")

const DASH_SPEED = 10.0
const DASH_DISTANCE = 5.0
const DASH_ACCELERATION = 10.0
const DASH_DECELERATION = 15.0
var dash_direction: Vector3 = Vector3.ZERO
var is_dashing = false
var dash_progress: float = 0.0
var is_jumping = false

var pathing_for_aoeslow = false

var salesman

var collider
var aa_target_pos
var aa_free = true #onko aa olemassa, tällä myös lähetetään vihollisen posia permana
var keep_aa #keep autoattackking
var target_found = false#flag for following enemy
var target
var target_pos 

#sekalaisia
#var parent = get_parent()
var dead = false #flag for whendead()
var timer
var liikkeessä
var nav_target_pos
var allow_moving
var prev_pos

#var player_hit
var allow_idle
var allow_run
var player_navigating
var mouse_pos
#var parent = get_parent()

# abilitien käyttämisen lukitus tila. Cd funktiot säätelevät näitä
var qLock = false
var wLock = false
var eLock = false
var rLock = false

# timerit ability cd funktiolle
var qTimer 
var wTimer 
var eTimer 
var rTimer 


#enemy projectiles areas
var spear = "Area3Dspearprojectile"

#player autoattack areas
var zombie_area = "Area3DZombie"

# ==ABILITIES LOAD==
var jump = load_ability("jump")
var stealth = load_ability("stealth")
var fireball = load_ability("fireball")
var bullet = load_ability("bullet")#spawner scene for projectile
var acidBall = load_ability("acidBall")
var autoattack = load_ability("autoattack")#spawner scene for projectile
var aoeslow = load_ability("aoeslow")

#animaatiot jotka estää juoksun ja idlen, cancellaus
var activeanimations = ["CastForwardRight","Jump","DramaticDeath","RunSlide","CastUpRight"]
var animplaying
var activeanimationplaying


func _ready():
	#navigationAgent.set_target_position(global_position)
	add_child(inventory)
	add_child(shop)
	salesman = get_node(salesman_path)
	add_child(targetmesh)
	targetmesh.visible = false
	gold_label.visible = false
#	autoattacktimer.start()
	play_animation("GetUpFromLayingOnBack",true)
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	#timer.timeout.connect(_on_timer_timeout)
	qTimer = Timer.new()  # create a new Timer
	add_child(qTimer)  # add it as a child
	qTimer.set_wait_time(1.0)  # set the wait time to 5 seconds
	qTimer.timeout.connect(_on_timer_timeoutq)
	
	wTimer = Timer.new()  # create a new Timer
	add_child(wTimer)  # add it as a child
	wTimer.set_wait_time(5.0)  # set the wait time to 5 seconds
	wTimer.timeout.connect(_on_timer_timeoutw)
	
	eTimer = Timer.new()  # create a new Timer
	add_child(eTimer)  # add it as a child
	eTimer.set_wait_time(5.0)  # set the wait time to 5 seconds
	eTimer.timeout.connect(_on_timer_timeoute)
	
	rTimer = Timer.new()  # create a new Timer
	add_child(rTimer)  # add it as a child
	rTimer.set_wait_time(10.0)  # set the wait time to 5 seconds
	rTimer.timeout.connect(_on_timer_timeoute)
	
func _read_input():
	#kääntyminen spellin suuntaan
	var camera = get_tree().get_nodes_in_group("Camera")[0]
	var mousePos = get_viewport().get_mouse_position()
	var rayLength = 100
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * rayLength
	var space = get_world_3d().direct_space_state #get_environment
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	#rayQuery.collide_with_areas = true
	rayQuery.collide_with_bodies = true
	var result = space.intersect_ray(rayQuery)
	if result.size() < 1:
		return
	mouse_pos = result.position
	var cast_to = global_position.direction_to(mouse_pos)
#	var x = self.global_position[0] + direction[0]
#	var z = self.global_position[2] + direction[2]
#	var suunta = Vector3(x, global_position.y, z)
	var suunta = Vector3(mouse_pos[0],global_position.y,mouse_pos[2])

#	if Input.is_action_just_pressed("q"):
#		look_at(suunta, Vector3.UP)
#		stealth.execute(self)
	if Input.is_action_just_pressed("q"):
		#print("to ",direction)
		look_at(suunta, Vector3.UP,true)
		play_animation("CastForwardRight",true)
		navigationAgent.set_target_position(self.position)
		bullet.mouse_position(cast_to)
		bullet_cast_sound.play()
		bullet.execute(self)
	if Input.is_action_just_pressed("r"):
		nodet3.alotaCDR()
		rLock = true
		rTimer.start()
		if global_position.distance_to(mouse_pos) > aoeslow_range:#? 
			nav_target_pos = mouse_pos
			navigationAgent.set_path_desired_distance(aoeslow_range)
			pathing_for_aoeslow = true # tarkistetaan physprosessissa
		if global_position.distance_to(mouse_pos) <= aoeslow_range:
			navigationAgent.set_target_position(self.position)
			aoeslow.mouse_position(mouse_pos)
			look_at(suunta, Vector3.UP,true)
			play_animation("CastUpRight", true)
			fireball_cast_sound.play()
		#aoesplash.mouse_position(mouse_pos)
#	if Input.is_action_just_pressed("e"):
##		o_player_position = global_position #vanhaa dashia varten
##		o_player_rotation = global_rotation
#		pass

		#stop pathing
	if (Input.is_action_just_pressed("s") or Input.is_action_pressed("s") 
	or Input.is_action_just_released("s")):
		navigationAgent.set_target_position(self.position)
		nav_target_pos = self.global_position
		allow_idle = true
		keep_aa = false
		#allow_run = false


#animation_list = []
func play_animation(animation,condition):
	#set_physics_process_internal(true)
	if condition:
		if animation == "Running":
			allow_idle = false
			anim_player.set_speed_scale(1)
			anim_player.play(animation)
		if animation == "Jump":
			#moveToPoint(0,0)
			allow_idle = false
			allow_run = false
			anim_player.stop()
			anim_player.set_speed_scale(1.9)
			anim_player.play(animation)
			await get_tree().create_timer(0.2).timeout
			anim_player.set_speed_scale(1.3)
		if animation == "CastForwardRight":#bullet
			#anim_player.set_blend_time("Running","CastForwardRight",2)
			allow_idle = false
			anim_player.stop()
			anim_player.set_speed_scale(8)
			anim_player.play(animation)
		if animation == "ThrowRight":#auto attack
			allow_idle = false
			anim_player.set_speed_scale(1.5)
			anim_player.play(animation)
		if animation == "NeutralIdle":
			anim_player.set_speed_scale(1)
			anim_player.play(animation)
		if animation == "PunchedFace":
			anim_player.set_speed_scale(2)
			#anim_player.stop()
			allow_idle = false
			anim_player.play(animation)
		if animation == "GetUpFromLayingOnBack":
			anim_player.set_speed_scale(2)
			anim_player.play(animation)
		if animation == "RunSlide":
			#anim_player.stop()
			allow_run = false
			allow_idle = false
			anim_player.set_speed_scale(3)
			anim_player.play(animation)
		if animation == "CastUpRight":
			anim_player.set_speed_scale(2)
			allow_run = false
			allow_idle = false
			anim_player.play(animation)
	if not condition and anim_player.get_current_animation() == animation:
		anim_player.stop()
		allow_idle = true
		
	#print(anim_player.current_animation)

func _on_animation_player_animation_finished(anim_name):
	allow_idle = true

func whendead():
		dead = true
		death_sound.play()
		anim_player.play("DramaticDeath")
		
func change_gold(value):
	gold += value
	inventory.change_gold(value)
	if value > 0:
		gold_label.text = "+" + str(value) + "g"
		gold_label.visible = true
		await get_tree().create_timer(1).timeout
		gold_label.visible = false

func change_exp(value):
	exp += value
	#level1
	if exp > 100:
		level = 2
		bar.update_level(level)
		health += 20 #paska tää koko systeemi




#sisältää liika paskaa jonka vois laittaa omiin funktiohin imo     -jep hyvää duunia
func _physics_process(delta):

	if health <= 0:
		kuolema()
	
	if pathing_for_aoeslow: #pathaus rangelle pääsyyn
		pathToGetToRange()

	#liikkeessä olemisen tunnistus, spagettia
	detectSelfMovement()
	
	#########===========autoattack==============##########
	autoAttack()

	#uusi dash? vähän paska mut toimii
	if eLock == false and Input.is_action_just_pressed("e") and is_dashing == false and (is_on_floor() or is_jumping):
		newDash()
	if is_dashing:
		dashJuttuja(delta)
	if dash_progress >= 1.0:
		is_dashing = false
		dash_direction = Vector3.ZERO
		dash_progress = 0.0

	#hyppy
	if is_on_floor():
			is_jumping = false
	if wLock == false and Input.is_action_just_pressed("w"):
		hyppyLogiikkaa()
	if not is_on_floor():
		velocity.y -= gravity *delta
		move_and_slide()

	if bar:
		bar.global_position = self.global_position
		bar.global_position[1] = 3.2
		bar.update_bar(health)
		
	#run animation rules 3===D
	runningLogic()
	
	
	#estää liikkumisen animaation aikana mutta liikkuu sen jälkeen
	stopMovementDuringAnimationAndMoveAfter()
		
	if (Input.is_action_just_pressed("q") or Input.is_action_just_pressed("w") or 
	Input.is_action_just_pressed("e") or Input.is_action_just_pressed("r")
	or Input.is_action_just_pressed("s")):
		_read_input()
	
	if(navigationAgent.is_navigation_finished()):
		return
	

	moveToPoint(delta, Speed)

func stopMovementDuringAnimationAndMoveAfter():
	if nav_target_pos == null:
		navigationAgent.set_target_position(global_position)
	if activeanimationplaying:
		navigationAgent.set_target_position(global_position)
	if not activeanimationplaying and nav_target_pos != null:
		navigationAgent.set_target_position(nav_target_pos)

func detectSelfMovement():
	if navigationAgent.is_navigation_finished():
		prev_pos = global_position
	if (prev_pos-global_position).length() > 0:
		liikkeessä = true
	if (prev_pos-global_position).length() <= 0:
		liikkeessä = false
	if liikkeessä == false and anim_player.get_current_animation() == "":
		allow_idle = true

func autoAttack():
	if not aa_free and not target == null:#lähettää vihun pos permana, aa ohjautuu
			autoattack.attack_target_position(target.global_position)
	if target_found and not target == null:
		nav_target_pos = global_position
		if keep_aa and not in_aa_range(target.global_position):
			#navigationAgent.set_target_position(target.global_position)
			nav_target_pos = target.global_position
			navigationAgent.set_path_desired_distance(aa_range)
		if keep_aa:
			auto_attack(target.global_position)
		if target.die():
			targetmesh.visible = false
			keep_aa = false
		if not target.die(): # punainen target nuoli
			targetmesh.global_transform.origin = target.global_position
			targetmesh.global_transform.origin.y = 4
			targetmesh.global_transform.origin.z += -1
			targetmesh.visible = true

func runningLogic():
	allow_run = not navigationAgent.is_navigation_finished()
	animplaying = anim_player.get_current_animation()
	activeanimationplaying = activeanimations.has(animplaying)

	if activeanimationplaying:
		allow_run = false

	play_animation("NeutralIdle",allow_idle)
	play_animation("Running",allow_run)
	#print("animation: ", anim_player.get_current_animation())
	#print("allowrun: ", allow_run)

func hyppyLogiikkaa():
	nodet.alotaCDW()
	wLock = true
	wTimer.start()
	if Input.is_action_just_pressed("w") and not is_jumping:
		if is_on_floor():
			play_animation("Jump",true)
			await get_tree().create_timer(0.17).timeout
			nav_target_pos = null
			is_jumping = true
			#navigationAgent.is_target_reachable()
			Speed = 10
			var suunta = Vector3.FORWARD.normalized()
			#velocity += suunta[1] + 10
			#nav_target_pos = suunta
			velocity.y +=  jump_speed
			#velocity.dir = 1.1
			move_and_slide()

func dashJuttuja(delta):
	play_animation("RunSlide", true)
	dash_cast_sound.play()
	var dash_vector = dash_direction * DASH_DISTANCE
	var dash_speed = DASH_SPEED
	nav_target_pos = null

	if dash_progress < 1.0:
		#print("h")
		dash_speed = lerp(0.0, DASH_SPEED, dash_progress)
		dash_progress += DASH_ACCELERATION * delta

	move_and_collide(dash_vector * dash_speed * delta)

func pathToGetToRange():
	if navigationAgent.is_navigation_finished() and global_position.distance_to(mouse_pos) <= aoeslow_range:
		pathing_for_aoeslow = false
		navigationAgent.set_target_position(self.position)
		aoeslow.mouse_position(mouse_pos)
		look_at(mouse_pos, Vector3.UP,true)
		play_animation("CastUpRight", true)
		fireball_cast_sound.play()
		navigationAgent.set_path_desired_distance(0.1)

func kuolema():
	get_tree().change_scene_to_file("res://Scenes/Levels/HavisitPelinScene.tscn")
	if die() and dead == false:
		whendead()

func newDash():
	nodet2.alotaCDE()
	eLock = true
	eTimer.start()
	is_dashing = true
	dash_direction = transform.basis.z.normalized() 

func moveToPoint(delta, speed):
	if is_on_floor(): #and not activeanimations.has(animplaying):
		#navigationAgent.set_target_position(nav_target_pos)
		var targetPos = navigationAgent.get_next_path_position()
		#navigationAgent.path_max_distance()
		var direction = global_position.direction_to(targetPos)
#		if activeanimationplaying:
#			direction = global_position.direction_to(mouse_pos)
		faceDirection(targetPos)
		velocity = direction * speed
#		print(self.global_rotation)
		#allow_run = true
		#navigationAgent.set_target_position(nav_target_pos)
		move_and_slide()

func faceDirection(direction):
	var kohta = Vector3(direction.x, global_position.y, direction.z)
	#look_at(kohta, Vector3.UP, true)
	rotation.y = lerp_angle(rotation.y, atan2(velocity.x, + velocity.z),1.0)
	#self.rotate(direction.x.normalized(),direction.z.normalized())
	#look_at(Vector3.FORWARD.rotated(Vector3.UP, rotation.y).lerp(direction, 0.1) + position)

#rightclick
func _input(event):
	if Input.is_action_just_pressed("RightMouse") or Input.is_action_pressed("RightMouse"):
		var camera = get_tree().get_nodes_in_group("Camera")[0]
		var mousePos = get_viewport().get_mouse_position()
		var rayLength = 100
		var from = camera.project_ray_origin(mousePos)
		var to = from + camera.project_ray_normal(mousePos) * rayLength
		var space = get_world_3d().direct_space_state
		var rayQuery = PhysicsRayQueryParameters3D.new()
		#rayQuery.set_shape(value)
		rayQuery.exclude = [self]
		rayQuery.from = from
		rayQuery.to = to
		#rayQuery.collide_with_areas = true
		rayQuery.set_collide_with_areas(false)
		rayQuery.set_collide_with_bodies(true)
		var result = space.intersect_ray(rayQuery)
		#estää crashin jos klikkaa ulos mapista
		if result.size() < 1:
			return
		var xyz = result.position
		var suunta = Vector3(xyz[0],global_position.y,xyz[2])
		collider = result.collider
		var distance = global_position.distance_to(result.position)
		var colliderpos = collider.global_position


		if not (collider is Enemy):
			#var mesh = target.get_node("targetmesh")
			if target_found and not target == null:
				targetmesh.visible = false#?
			aa_free = true
			target_found = false
			keep_aa = false
			Speed = 5
			#if is_dashing == false:
			navigationAgent.set_path_desired_distance(0.2)
			nav_target_pos = result.position
				#navigationAgent.set_target_position(nav_target_pos)
		
		#autoattack
		if collider is Enemy:# autoattacktimer.time_left <= 0.1:
			#print(collider)
			target = collider
			keep_aa = true
			target_found = true
			#print(collider)
			autoattack.target_getter(collider)#nyt aa menee vihun läpi ja tekee kumpaanki dmg : D
			
			#aa_target_pos = collider.global_position
		
		if collider is Salesman:
			shop.visible = true
			nav_target_pos = global_position

func buy_item(cost):#testaa jos rahat riittää shop skenestä
	if gold >= int(cost):
		shop.buy_from_shop()
		change_gold(-cost)

func add_item(item_scene,item_name):#item skene menee inventoryyn ja nimi omaan listaan
	#if not item_list.has(item_name):
		inventory.add_item_to_inventory(item_scene)#tulee kokonainen itemin skene instance inventory skeneen
		#items = inventory.check_inventory()#lisää omat itemit pelaajalla olevaan listaan
		item_list.append(item_name)
		salesman.item_bought()#hieno kolikke audio
		### ja lisää statsit #####
		attack_dmg = base_attack_dmg + inventory.return_stats("attack damage")#saadaan statsit inventory skenestä
		#print(item_list)

func shop_was_closed():
	salesman.shop_was_closed()#myyjä tekee hienon heilutuksen

#zombie melee hit
func hit(hit):
	#emit_signal("player_hit")
	#velocity += dir * HIT_STAGGER
	if hit: #vain melee
		change_health(-15)
		#play_animation("PunchedFace",true)

#damagen ottamine
func _on_area_3d_area_entered(area):
	if area:
		var string = (str(area))
		var is_spear = string.substr(0,len(spear))
		if is_spear == spear:
			health += -20
			allow_idle = false
			if !activeanimationplaying:
				play_animation("PunchedFace",true)
		var ryhmat = area.get_groups()
		for x in ryhmat:
			if x == "tappo":
				health += -500
			if x == "piikit":
				health -= 5
			
		

func auto_attack(targetpos):
	if in_aa_range(targetpos):
		var suunta = Vector3(targetpos[0],global_position.y,targetpos[2])
		#var enemy area = get_tree().add_child(Area3D.new)
		navigationAgent.set_target_position(self.position)
		#autoattacktimer.stop()
		#autoattacktimer.start()
		look_at(suunta, Vector3.UP, true)
		play_animation("ThrowRight", true)

func aa_animation_moment(pos):#aa animaation h hetki, spawnaa aa
	navigationAgent.set_target_position(self.position)
	autoattack.attack_target_position(target.global_position)
	autoattack.execute(self)
	
func cast_up_moment():#cast_up animaatop h hetki
	aoeslow.execute(self)

func in_aa_range(targetpos):
	return global_position.distance_to(targetpos) <= aa_range
	
func aa_freed():
	aa_free = false

func aa_dmg_returner():
	return autoattack_dmg

func bullet_dmg_returner():
	var bullet_dmg = 20 * level + attack_dmg * 0.7 #onko hyvä ratio?
	return bullet_dmg

func aoeslow_dmg_returner():
	return aoeslow_dmg
	
#func dmg_returner(dmgsource):
#	#koitin tehdä koodista järkevämpää, ei toimi vielä
#	return dmgsource + "_dmg"
#	if dmgsource == bullet:
#		return bullet_dmg
#	if dmgsource == aoeslow:
#		return aoeslow_dmg
#	if dmgsource == autoattack:
#		return autoattack_dmg


func _on_timer_timeoutq():
	qLock = false
	qTimer.stop()
func _on_timer_timeoutw():
	wLock = false
	wTimer.stop()
func _on_timer_timeoute():
	eLock = false
	eTimer.stop()


func _on_area_3d_body_entered(body):
	var ryhmat = body.get_groups()
	for x in ryhmat:
		if x == "arrow":
			health -= 10
