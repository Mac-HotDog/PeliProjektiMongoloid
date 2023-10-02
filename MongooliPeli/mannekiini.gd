extends Entity

var exp = 0
@export var Speed = 4.5
@export var gravity = 6
@export var jump_speed = 3.5
@onready var gold_label = $Label3DGold
@onready var bar = $Resourcebar
@onready var navigationAgent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@export var inventoryscene = preload("res://Scenes/HUD/inventorynew.tscn")
@onready var inventory = inventoryscene.instantiate()
@export var shopscene = preload("res://Scenes/HUD/shop.tscn")
@onready var shop = shopscene.instantiate()
@export var salesman_path := "/root/level1/salesman"
var salesman

#audio
@onready var bullet_cast_sound = $audiobulletcast
@onready var fireball_cast_sound =$audiofireballcast #nykyään lumimyrsky
@onready var death_sound = $audiodeath

#dmg numbers
@export var base_attack_dmg = 12
var attack_dmg = base_attack_dmg
@export var aoeslow_dmg = 7
#ranges
@export var aa_range = 8
@export var aoeslow_range = 15
var pathing_for_aoeslow = false#tarviiko päästä w rangelle
#dashia varten..
@onready var dash_cast_sound = $audiodashcast
const DASH_SPEED = 10.0
const DASH_DISTANCE = 5.0
const DASH_ACCELERATION = 10.0
const DASH_DECELERATION = 15.0
var dash_direction: Vector3 = Vector3.ZERO
var is_dashing = false
var dash_progress: float = 0.0
var is_jumping = false

# aa varten
@onready var targetmeshinstance = preload("res://Scenes/HUD/redarrowsprite.tscn")
@onready var targetmesh = targetmeshinstance.instantiate()
@onready var autoattacktimer = $AutoAttackTimer # ei käytössä
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
var aoeslow_cast_pos


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
	#state_machine = anim_tree.get("parameters/playback")
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	#timer.timeout.connect(_on_timer_timeout)
	
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
	if Input.is_action_just_pressed("w"):
		if global_position.distance_to(mouse_pos) > aoeslow_range:#? 
			nav_target_pos = mouse_pos
			aoeslow_cast_pos = mouse_pos
			#navigationAgent.set_target_position(aoeslow_cast_pos)
			navigationAgent.set_path_desired_distance(aoeslow_range)
			pathing_for_aoeslow = true # tarkistetaan physprosessissa
		if global_position.distance_to(mouse_pos) <= aoeslow_range:
			navigationAgent.set_target_position(self.position)
			aoeslow.mouse_position(mouse_pos)
			look_at(suunta, Vector3.UP,true)
			play_animation("CastUpRight", true)
			fireball_cast_sound.play()
		#aoesplash.mouse_position(mouse_pos)
	if Input.is_action_just_pressed("e"):
#		o_player_position = global_position #vanhaa dashia varten
#		o_player_rotation = global_rotation
		pass

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
		if animation == "CastForwardRight":#bullet, ezreal q
			#anim_player.set_blend_time("Running","CastForwardRight",2)
			allow_idle = false
			anim_player.stop()
			anim_player.set_speed_scale(6.5)
			anim_player.play(animation)
		if animation == "ThrowRight":#auto attack
			allow_idle = false
			anim_player.set_speed_scale(1.3)
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
#	if not condition and anim_player.get_current_animation() == animation:
#		anim_player.stop()
#		allow_idle = true
		
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

func _physics_process(delta):
	animplaying = anim_player.get_current_animation()

	if die() and dead == false:
		whendead()


	if pathing_for_aoeslow:#pathaus rangelle pääsyyn
		#if navigationAgent.is_target_reached():
		if navigationAgent.is_navigation_finished() and global_position.distance_to(mouse_pos) <= aoeslow_range:
			nav_target_pos = null
			aoeslow.mouse_position(aoeslow_cast_pos)
			look_at(aoeslow_cast_pos, Vector3.UP,true)
			play_animation("CastUpRight", true)
			fireball_cast_sound.play()
			pathing_for_aoeslow = false
			navigationAgent.set_path_desired_distance(1)

	#liikkeessä olemisen tunnistus, spagettia
	if navigationAgent.is_navigation_finished():
		prev_pos = global_position
	if (prev_pos-global_position).length() > 0:
		liikkeessä = true
	if (prev_pos-global_position).length() <= 0:
		liikkeessä = false
	if liikkeessä == false and anim_player.get_current_animation() == "Running":
		allow_idle = true
	
	#########===========autoattack==============##########
	if not aa_free and target != null:#lähettää vihun pos permana, aa ohjautuu
			autoattack.attack_target_position(target.global_position)
	if target_found and target != null:
		nav_target_pos = global_position
		if keep_aa and not in_aa_range(target.global_position):
			#navigationAgent.set_target_position(target.global_position)
			nav_target_pos = target.global_position
			navigationAgent.set_path_desired_distance(aa_range)
		if keep_aa and animplaying != "CastForwardRight":#tärkeä
			auto_attack(target.global_position)
		if target.die():
			targetmesh.visible = false
			keep_aa = false
			target = null
		if target != null: # punainen target nuoli
			if not target.die():
				targetmesh.global_transform.origin = target.global_position
				targetmesh.global_transform.origin.y = 4
				targetmesh.global_transform.origin.z += -1
				targetmesh.visible = true


	#uusi dash? vähän paska mut toimii
	if Input.is_action_just_pressed("e") and is_dashing == false and (is_on_floor() or is_jumping):
		is_dashing = true
		dash_direction = transform.basis.z.normalized() 
	#print(is_dashing)
	if is_dashing:
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
		#print(dash_speed)
		if dash_progress >= 1.0:
			is_dashing = false
			dash_direction = Vector3.ZERO
			dash_progress = 0.0

	#hyppy
	if is_on_floor():
			is_jumping = false
	if Input.is_action_just_pressed("r") and not is_jumping:
		if is_on_floor():
			play_animation("Jump",true)
			await get_tree().create_timer(0.17).timeout
			nav_target_pos = null
			is_jumping = true
			#navigationAgent.is_target_reachable()
			#Speed = 10
			var suunta = Vector3.FORWARD.normalized()
			velocity.y +=  jump_speed
			move_and_slide()
			#move_and_collide(Vector3.FORWARD)
	if not is_on_floor():
		velocity.y -= gravity *delta
		move_and_slide()

	if bar:
		bar.global_position = self.global_position
		bar.global_position[1] = 3.2
		bar.update_bar(health)
#	if manaBar:
#		manaBar.update_bar(mana)


		
#ranimation rules 3===D
	allow_run = not navigationAgent.is_navigation_finished()
	activeanimationplaying = activeanimations.has(animplaying)

	if activeanimationplaying: #or anim_player.get_current_animation() == "ThrowRight":
		allow_run = false

	play_animation("NeutralIdle",allow_idle)
	play_animation("Running",allow_run)

	#estää liikkumisen animaation aikana mutta liikkuu sen jälkeen
	if nav_target_pos == null:
		navigationAgent.set_target_position(global_position)
	if activeanimationplaying:
		navigationAgent.set_target_position(global_position)
	if not activeanimationplaying and nav_target_pos != null:
		navigationAgent.set_target_position(nav_target_pos)


	if (Input.is_action_just_pressed("q") or Input.is_action_just_pressed("w") or 
	Input.is_action_just_pressed("e") or Input.is_action_just_pressed("r")
	or Input.is_action_just_pressed("s")):
		_read_input()

	if shop.visible == true:
		salesman.shop_open(true)
	if shop.visible == false:
		salesman.shop_open(false)
	#print(navigationAgent.is_target_reachable())
	if(navigationAgent.is_navigation_finished()):
		return
	

	moveToPoint(delta, Speed)


func moveToPoint(delta, speed):
	if is_on_floor(): #and not activeanimations.has(animplaying):
		var targetPos = navigationAgent.get_next_path_position()
		#navigationAgent.path_max_distance()
		var direction = global_position.direction_to(targetPos)
#		if activeanimationplaying:
#			direction = global_position.direction_to(mouse_pos)
		faceDirection(targetPos)
		velocity = direction * speed
		#navigationAgent.set_target_position(nav_target_pos)
		move_and_slide()

func faceDirection(direction):
	var kohta = Vector3(direction.x, global_position.y, direction.z)
	look_at(kohta, Vector3.UP, true)
	#rotation.y = lerp_angle(rotation.y, atan2(velocity.x, + velocity.z),1.0)
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

		rayQuery.from = from
		rayQuery.to = to
		rayQuery.set_collide_with_areas(false)
		rayQuery.set_collide_with_bodies(true)
		var result = space.intersect_ray(rayQuery)
		if result.size() < 1:#estää crashin jos klikkaa ulos mapista
			return
		var xyz = result.position
		var suunta = Vector3(xyz[0],global_position.y,xyz[2])
		collider = result.collider
		var distance = global_position.distance_to(result.position)
		var colliderpos = collider.global_position


		if not (collider is Enemy or collider.get_parent() is TextureRect):
			#var mesh = target.get_node("targetmesh")
			if target_found and not target == null:
				targetmesh.visible = false
			aa_free = true
			target_found = false
			keep_aa = false
			Speed = 5
			#if is_dashing == false:
			navigationAgent.set_path_desired_distance(1)
			nav_target_pos = result.position
				#navigationAgent.set_target_position(nav_target_pos)
		#print("hahmon saama" ,result.collider)
		
		#autoattack
		if collider is Enemy:# autoattacktimer.time_left <= 0.1:
			target = collider
			keep_aa = true
			target_found = true
			#print(collider)
			#lähettää aa projektilelle tiedon 
			autoattack.target_getter(collider)#nyt aa menee vihun läpi ja tekee kumpaanki dmg : D
			
			#aa_target_pos = collider.global_position
		if collider is Salesman:
			#navigationAgent.set_target_position(self.position)
			nav_target_pos = global_position
			shop.visible = true

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
	if hit: #vain zombie? melee
		change_health(-15)
		#play_animation("PunchedFace",true)


func _on_area_3d_area_entered(area):
	if area:
		var string = (str(area))
		var is_spear = string.substr(0,len(spear))
		if is_spear == spear:
			health += -20
			allow_idle = false
			if !activeanimationplaying and keep_aa == false:
				play_animation("PunchedFace",true)
		var ryhmat = area.get_groups()
		for x in ryhmat:
			if x == "tappo":
				health += -500
			if x == "piikit":
				health -= 5
		

#func _on_area_3d_area_exited(area):
#	timer.stop()
#
#func _on_timer_timeout():
#	health += -5

	
func auto_attack(targetpos):
	if in_aa_range(targetpos): #and target != null and not activeanimationplaying:
		var suunta = Vector3(targetpos[0],global_position.y,targetpos[2])
		#var enemy area = get_tree().add_child(Area3D.new)
		navigationAgent.set_target_position(self.position)
		#autoattacktimer.stop()
		#autoattacktimer.start()
		look_at(suunta, Vector3.UP, true)
		play_animation("ThrowRight", true)#aloittaa animaation joka spawnaa aa


func aa_animation_moment(pos):#aa animaation h hetki, spawnaa aa
	if target != null:
		navigationAgent.set_target_position(self.position)
		autoattack.attack_target_position(target.global_position)
		autoattack.execute(self)
	
func cast_up_moment():#cast_up animaatop h hetki
	aoeslow.execute(self)

func in_aa_range(targetpos):
	return global_position.distance_to(targetpos) <= aa_range
	
func aa_freed():
	aa_free = false

func aa_dmg_returner():#nämä returnerit vois varmaan siirtää entity scriptiin(muuttujat mukana)
	return attack_dmg

func bullet_dmg_returner():
	var bullet_dmg = 20 * level + attack_dmg * 0.7
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


