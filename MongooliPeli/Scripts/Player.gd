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
var acidBall = load_ability("acidBall")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _read_input():
	#if Input.is_action_just_pressed("w") : jump.execute(self, 4)
	if Input.is_action_just_pressed("q") : stealth.execute(self)
	if Input.is_action_just_pressed("w") : acidBall.execute(self)
	
func _physics_process(delta):
	_read_input()
	
	if bar:
		bar.update_bar(health)
	if manaBar:
		manaBar.update_bar(mana)
	if(navigationAgent.is_navigation_finished()):
		return
	moveToPoint(delta, Speed)
	
	#vanhat jump koodit
	#velocity.y += gravity * delta
	# Handle Jump.
	#if Input.is_action_just_pressed("w") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		
	#vanhat koodit
#	if target:
#		look_at(target, Vector3.UP)
#		rotation.x = 0
#		velocity = -transform.basis.z * speed
#		if transform.origin.distance_to(target) < .5:
#			target = Vector3.ZERO
#			velocity = Vector3.ZERO
	
	
func moveToPoint(delta, speed):
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed
	move_and_slide()

func faceDirection(direction):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

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
		navigationAgent.target_position = result.position












func _on_area_3d_area_entered(area):
	if area:
		health += -5
