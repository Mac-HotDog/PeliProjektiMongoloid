extends Entity



#var target = Vector3.ZERO
# ==ABILITIES LOAD==
var jump = load_ability("jump")
var stealth = load_ability("stealth")
var fireball = load_ability("fireball")

const bulletpath = preload("res://Scenes/bullet.tscn")

func _read_input():
	#if Input.is_action_just_pressed("w") : jump.execute(self, 4)
	if Input.is_action_just_pressed("q") : stealth.execute(self)
	if Input.is_action_just_pressed("w"): fireball.execute(self)
	if Input.is_action_just_pressed("e"): _bullet()
	
func _bullet():
		

		
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

		
		look_at(suunta, Vector3.UP)

		

		var bullet = bulletpath.instantiate()
		get_parent().add_child(bullet)
		#var bullet_direction = Vector2(5,5)
		#var spawn =
		bullet.position = suunta
		




@onready var navigationAgent : NavigationAgent3D = $NavigationAgent3D
var Speed = 5
# Called when the node enters the scene tree for the first time.

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_read_input()
	

	if(navigationAgent.is_navigation_finished()):
		return
	moveToPoint(delta, Speed)




func moveToPoint(delta, speed):
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed

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
		
		if result.size() < 1:
			return
		
		#navigationAgent.target_position = result.position
		navigationAgent.set_target_position(result.position)

		
	
	

#func hit(dir):
	#emit_signal("player_hit")
	#velocity += dir * HIT_STAGGER









