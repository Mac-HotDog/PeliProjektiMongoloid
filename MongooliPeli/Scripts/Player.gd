extends Entity

@export var speed = 5
@export var gravity = -5
@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var navigationAgent : NavigationAgent3D = $NavigationAgent3D

var target = Vector3.ZERO
var Speed = 5

# ==ABILITIES LOAD==
var jump = load_ability("jump")
var stealth = load_ability("stealth")
var fireball = load_ability("fireball")
var bullet = load_ability("bullet")
var acidBall = load_ability("acidBall")
var timer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
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
	var result = space.intersect_ray(rayQuery)
	
	if result.size() < 1:
		return
			
	var xyz = result.position
	var direction = global_position.direction_to(xyz)
	var x = self.global_position[0] + direction[0]
	var z = self.global_position[2] + direction[2]
	var suunta = Vector3(x, global_position.y, z)



#	if Input.is_action_just_pressed("w"):
#		jump.execute(self,4)
	if Input.is_action_just_pressed("q"):
		look_at(suunta, Vector3.UP)
		stealth.execute(self)
	if Input.is_action_just_pressed("w"):
		look_at(suunta, Vector3.UP)
		fireball.execute(self)
	if Input.is_action_just_pressed("e"):
		look_at(suunta, Vector3.UP)
		bullet.mouse_position(xyz)
		bullet.execute(self)





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if bar:
		bar.update_bar(health)
	if manaBar:
		manaBar.update_bar(mana)
	if health < 0:
		get_tree().change_scene_to_file("res://Scenes/Levels/HavisitPelinScene.tscn")
	if Input.is_action_just_pressed("q") or Input.is_action_just_pressed("w") or Input.is_action_just_pressed("e"):
		_read_input()
	

	if(navigationAgent.is_navigation_finished()):
		return
	moveToPoint(delta, Speed)




func moveToPoint(delta, speed):
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed
	print(targetPos)
	move_and_slide()



func faceDirection(direction):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)
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
		
		
		
		#print("hahmon saama" ,result, "markkerii" )
		
		#estää crashin jos klikkaa ulos mapista
		if result.size() < 1:
			return
		
		#navigationAgent.target_position = result.position
		navigationAgent.set_target_position(result.position)

		
	
	

#func hit(dir):
	#emit_signal("player_hit")
	#velocity += dir * HIT_STAGGER






func _on_area_3d_area_entered(area):
	if area:
		health += -5
		timer.start()
		



func _on_area_3d_area_exited(area):
	timer.stop()
	
func _on_timer_timeout():
	health += -5
