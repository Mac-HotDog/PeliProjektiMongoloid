extends Entity


var target = Vector3.ZERO
@export var speed = 5
@export var gravity = -5
#var target = Vector3.ZERO
# ==ABILITIES LOAD==
var jump = load_ability("jump")
var stealth = load_ability("stealth")
	
func _read_input():
	#if Input.is_action_just_pressed("w") : jump.execute(self, 4)
	if Input.is_action_just_pressed("q") : stealth.execute(self)
	
	
func _physics_process(delta):
	_read_input()
	move_and_slide()
	#velocity.y += gravity * delta
	# Handle Jump.
	#if Input.is_action_just_pressed("w") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	if target:
		look_at(target, Vector3.UP)
		rotation.x = 0
		velocity = -transform.basis.z * speed
		if transform.origin.distance_to(target) < .5:
			target = Vector3.ZERO
			velocity = Vector3.ZERO
	
	
	











