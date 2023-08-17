extends Entity

@export var Speed = 5
@export var gravity = 6
@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var navigationAgent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var model = $Armature/Skeleton3D
@onready var bullet_cast_sound = $audiobulletcast
@onready var fireball_cast_sound =$audiofireballcast
@onready var dash_marker = $Marker3Ddash
@onready var dash_cast_sound = $audiodashcast
@onready var autoattacktimer = $AutoAttackTimer

#dashia varten..
var dash_marker_o_position
var o_player_position
var o_player_rotation


#var parent = get_parent()





#var Speed = 5
var timer
#var player_hit
var allow_idle
var allow_run
var player_navigating
var jump_speed = 3
var fornow = false

#enemy projectiles areas
var spear = "Area3Dspearprojectile"

#player autoattack areas
var zombie_area = "Area3DZombie"

# ==ABILITIES LOAD==
var jump = load_ability("jump")
var stealth = load_ability("stealth")
var fireball = load_ability("fireball")
var bullet = load_ability("bullet")
var acidBall = load_ability("acidBall")
var autoattack = load_ability("autoattack")


func _ready():
	autoattacktimer.start()
	play_animation("GetUpFromLayingOnBack",true)
	dash_marker_o_position = dash_marker.position
	#state_machine = anim_tree.get("parameters/playback")
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.timeout.connect(_on_timer_timeout)
	
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
	var xyz = result.position
	var cast_to = global_position.direction_to(xyz)
#
#	var x = self.global_position[0] + direction[0]
#	var z = self.global_position[2] + direction[2]
#	var suunta = Vector3(x, global_position.y, z)
	var suunta = Vector3(xyz[0],global_position.y,xyz[2])

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
		look_at(suunta, Vector3.UP,true)
		fireball_cast_sound.play()
		fireball.execute(self)
	if Input.is_action_just_pressed("e"):
		o_player_position = global_position
		o_player_rotation = global_rotation
		dash()

		#stop pathing
	if (Input.is_action_just_pressed("s") or Input.is_action_pressed("s") 
	or Input.is_action_just_released("s")):
		navigationAgent.set_target_position(self.position)
		#allow_run = false


func dash():
		var player_pos = global_position
		var vector_to_marker = dash_marker.global_position - global_position
		var vektori = vector_to_marker.normalized()
		var max_range = vector_to_marker.length()
		var marker_location = dash_marker.global_position
		var direction_to = global_position.direction_to(dash_marker.position)
		
		play_animation("RunSlide",true)
		Speed = 28
		navigationAgent.set_target_position(marker_location)
		await get_tree().create_timer(0.001).timeout
		if abs(global_rotation[1] - o_player_rotation[1]) > 2:
			global_position = o_player_position
			global_rotation = o_player_rotation
			navigationAgent.set_target_position(self.position)
			#dash_marker.transform_origin[2] += -1
			navigationAgent.set_target_position(marker_location)
		else:
			#navigationAgent.set_target_position(dash_marker_o_position)#????
			dash_cast_sound.play()
	
		
		#navigationAgent.set_path_desired_distance(20)
		#navigationAgent.set_path_max_distance()
		#print(global_position.distance_to(navigationAgent.get_target_position()))
		#print(navigationAgent.get_current_navigation_path_index())
		#print(navigationAgent.get_current_navigation_result()

		#transform.origin = marker_location


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
		if animation == "CastForwardRight":#bullet
			#anim_player.set_blend_time("Running","CastForwardRight",2)
			allow_idle = false
			anim_player.stop()
			anim_player.set_speed_scale(10)
			anim_player.play(animation)
		if animation == "ThrowRight":
			allow_idle = false
			anim_player.set_speed_scale(2)
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
		if animation == "RunSlide": # ei omaa animaatiota eikä toimi?
			#anim_player.stop()
			allow_run = false
			allow_idle = false
			anim_player.set_speed_scale(3)
			anim_player.play("RunSlide")
	if not condition and anim_player.get_current_animation() == animation:
		anim_player.stop()
		allow_idle = true


		#print(anim_player.current_animation)





func _physics_process(delta):
	if die():
		anim_player.play("DramaticDeath")
	
	#hyppy
	if Input.is_action_just_pressed("r"):
		if is_on_floor():
			#navigationAgent.is_target_reachable()
			play_animation("Jump",true)
			velocity.y +=  jump_speed
			#velocity.dir = 1.1
			#print(Vector3.FORWARD)
			move_and_slide()
	if not is_on_floor():
		velocity.y -= gravity *delta
		move_and_slide()


	allow_run = not navigationAgent.is_navigation_finished()
	if anim_player.get_current_animation() == "RunSlide":
		allow_run = false
	if anim_player.get_current_animation() == "CastForwardRight":
		allow_run = false
	if Input.is_action_pressed("s"):
		allow_run = false
	
	
	
	play_animation("NeutralIdle",allow_idle)
	play_animation("Running",allow_run)
	#print("animation: ", anim_player.get_current_animation())
	#print("allowrun: ", allow_run)



	if bar:
		bar.update_bar(health)
	if manaBar:
		manaBar.update_bar(mana)

	if (Input.is_action_just_pressed("q") or Input.is_action_just_pressed("w") or 
	Input.is_action_just_pressed("e") or Input.is_action_just_pressed("r")
	or Input.is_action_just_pressed("s")):
		_read_input()


	
	if(navigationAgent.is_navigation_finished()):
		return
	#if await q_pressed(1) == false:
	moveToPoint(delta, Speed)




func moveToPoint(delta, speed):
	if is_on_floor() and not Input.is_action_pressed("s"):
		var targetPos = navigationAgent.get_next_path_position()
		#navigationAgent.path_max_distance()
		var direction = global_position.direction_to(targetPos)
		faceDirection(targetPos)
		velocity = direction * speed
#		print(self.global_rotation)
		#allow_run = true

		move_and_slide()


func faceDirection(direction):
	var kohta = Vector3(direction.x, global_position.y, direction.z)
	look_at(kohta, Vector3.UP,true)
	#self.rotate(direction.x.normalized(),direction.z.normalized())
	#look_at(Vector3.FORWARD.rotated(Vector3.UP, rotation.y).lerp(direction, 0.1) + position)

#input to move to 
func _input(event):
	if Input.is_action_just_pressed("RightMouse") or Input.is_action_pressed("RightMouse"):
		var camera = get_tree().get_nodes_in_group("Camera")[0]
		var mousePos = get_viewport().get_mouse_position()
		var rayLength = 100
		var from = camera.project_ray_origin(mousePos)
		var to = from + camera.project_ray_normal(mousePos) * rayLength
		var space = get_world_3d().direct_space_state
		var rayQuery = PhysicsRayQueryParameters3D.new()
		rayQuery.from = from
		rayQuery.to = to
		#rayQuery.collide_with_areas = true
		rayQuery.set_collide_with_areas(true)
		#rayQuery.set_collide_with_bodies(false)
		#rayQuery.set_collision_mask()
		
		var result = space.intersect_ray(rayQuery)
		if result.size() < 1:
			return
		var xyz = result.position
		#print("hahmon saama" ,result)
		
		var suunta = Vector3(xyz[0],global_position.y,xyz[2])
		var collider = str(result.collider)
		if collider.substr(0,len(zombie_area)) == zombie_area and autoattacktimer.time_left <= 0.1:
			autoattacktimer.start()
			navigationAgent.set_target_position(self.position)
			play_animation("ThrowRight", true)
			look_at(suunta,Vector3.UP,true)
			autoattack.attack_target(result.position)
			autoattack.execute(self)
			#print("osuma zombiin")
		
		#estää crashin jos klikkaa ulos mapista
		
		
		#navigationAgent.target_position = result.position
		if collider.substr(0,len(zombie_area)) != zombie_area:
			Speed = 5
			navigationAgent.set_target_position(result.position)
		


#zombie melee hit
func hit(hit):
	#emit_signal("player_hit")
	#velocity += dir * HIT_STAGGER
	if hit: #vain melee
		change_health(-15)
		allow_idle = false
		play_animation("PunchedFace",true)






func _on_area_3d_area_entered(area):
	if area:
		var string = (str(area))
		var is_spear = string.substr(0,len(spear))
		if is_spear == spear:
			health += -200
			allow_idle = false
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


func _on_animation_player_animation_finished(anim_name):
	#set_physics_process_internal(true)
	allow_idle = true







