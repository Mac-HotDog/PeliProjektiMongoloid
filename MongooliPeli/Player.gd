extends CharacterBody3D


@export var speed = 5
@export var gravity = -5

var target = Vector3.ZERO

const JUMP_VELOCITY = 4.5

func _physics_process(delta):
	velocity.y += gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("w") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if target:
		look_at(target, Vector3.UP)
		rotation.x = 0
		velocity = -transform.basis.z * speed
		if transform.origin.distance_to(target) < .5:
			target = Vector3.ZERO
			velocity = Vector3.ZERO
	move_and_slide()
	if Input.is_action_just_pressed("q"):
		visible = false
		await get_tree().create_timer(1).timeout
		visible = true
	


