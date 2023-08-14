extends Entity

@export var SPEED = 5
@export var gravity = 6
@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var navigationAgent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var model = $Armature/Skeleton3D
@onready var bullet_cast_sound = $audiobulletcast
@onready var fireball_cast_sound =$audiofireballcast

#signal player_hit


var Speed = 5
var leap_strength = 10
var timer
#var player_hit
var allow_idle
var allow_run
var player_navigating
var jump_speed = 6
var fornow = false
var leap_direction
#enemy projectiles areas
var spear = "Area3Dspearprojectile"

# ==ABILITIES LOAD==
#var jump = load_ability("jump")
var stealth = load_ability("stealth")
var fireball = load_ability("fireball")
var bullet = load_ability("bullet")
var acidBall = load_ability("acidBall")


func _ready():
	allow_idle = true
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
	var space = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	rayQuery.collide_with_areas = true
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
	leap_direction = suunta
	if Input.is_action_just_pressed("q"):
		look_at(suunta, Vector3.UP)
		stealth.execute(self)
	if Input.is_action_just_pressed("w"):
		look_at(suunta, Vector3.UP,true)
		fireball_cast_sound.play()
		fireball.execute(self)
	if Input.is_action_just_pressed("e"):
		#print("to ",direction)
		look_at(suunta, Vector3.UP,true)
		e_pressed(0)
		bullet.mouse_position(cast_to)
		bullet_cast_sound.play()
		bullet.execute(self)
	#stop pathing
	if Input.is_action_just_pressed("s"):
		navigationAgent.set_target_position(self.position)


func play_animation(animation,condition):
	if condition:
		if animation == "Running":
			allow_idle = false
			anim_player.set_speed_scale(1)
			anim_player.play(animation)
		if animation == "Jump":
			#moveToPoint(0,0)
			allow_idle = false
			anim_player.stop()
			anim_player.set_speed_scale(1.6)
			anim_player.play(animation)
		if animation == "CastForwardRight":
			#anim_player.set_blend_time("Running","CastForwardRight",2)
			allow_idle = false
			anim_player.stop()
			anim_player.set_speed_scale(10)
			anim_player.play(animation)
		if animation == "NeutralIdle":
			anim_player.set_speed_scale(1)
			anim_player.play(animation)
		if animation == "PunchedFace":
			#anim_player.stop()
			allow_idle = false
			anim_player.play(animation)
			
	#if not condition and anim_player.get_animation(animation) == animation:
		#anim_player.stop(animation)


		#print(anim_player.current_animation)

# allow e animtion
func e_pressed(over):
	if over == 0:
		fornow = true
		allow_idle = false
		allow_run = false
		play_animation("CastForwardRight",fornow)
		await get_tree().create_timer(0.4).timeout
		allow_run = true
		fornow = false
	if over == 1:
		return fornow
		
#	if over == 1: #saadaan signaalista
#		fornow = false
#		play_animation("CastForwardRight",fornow)
func leap():
	# Apply the leap in the specified direction
	velocity += leap_direction * leap_strength
	pass


func _physics_process(delta):
#	if Input.is_action_just_pressed("r"):
#		if is_on_floor():
#			play_animation("Jump",true)
#			velocity.y +=  jump_speed
#			#velocity.dir = 1.1
#			#print(Vector3.FORWARD)
#			move_and_slide()
	#if not is_on_floor():
		#velocity.y -= gravity *delta
	move_and_slide()
	#print(anim_player.get_current_animation())
	if Input.is_action_just_pressed("r"):
		if is_on_floor():
			leap()
			
	allow_run = not navigationAgent.is_navigation_finished()
	if is_on_floor():
		play_animation("NeutralIdle",allow_idle)
	#print(anim_player.get_current_animation())


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
	if await e_pressed(1) == false:
		
			moveToPoint(delta, Speed)




func moveToPoint(delta, speed):
	if is_on_floor():
		var targetPos = navigationAgent.get_next_path_position()
		var direction = global_position.direction_to(targetPos)
		faceDirection(targetPos)
		velocity = direction * speed
#		print(self.global_rotation)
		allow_run = true
		play_animation("Running",allow_run)
		move_and_slide()


func faceDirection(direction):
	var kohta = Vector3(direction.x, global_position.y, direction.z)
	look_at(kohta, Vector3.UP,true)
	#self.rotate(direction.x.normalized(),direction.z.normalized())
	#look_at(Vector3.FORWARD.rotated(Vector3.UP, rotation.y).lerp(direction, 0.1) + position)

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
		rayQuery.collide_with_areas = true
		var result = space.intersect_ray(rayQuery)

		
		
		#print("hahmon saama" ,result, "markkerii")
		
		#estää crashin jos klikkaa ulos mapista
		if result.size() < 1:
			return
		
		#navigationAgent.target_position = result.position
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

		#health += -5
		#timer.start()
		



func _on_area_3d_area_exited(area):
	timer.stop()

func _on_timer_timeout():
	health += -5


func _on_animation_player_animation_finished(anim_name):
#	play_animation("NeutralIdle", true)
#	if anim_name == "CastForwardRight":
#		e_pressed(1)
	allow_idle = true

