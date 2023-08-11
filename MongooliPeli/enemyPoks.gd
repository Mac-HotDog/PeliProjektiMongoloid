extends MeshInstance3D

var timer
var decal_scene = preload("res://splatter.tscn")
var decal_instance
var result
var collision_normal
func _ready():
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.set_one_shot(true)  # make it a one-shot timer
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	

func _on_timer_timeout():
	# Get the physics space state to perform a raycast
	var space_state = get_world_3d().direct_space_state

	# Define the starting point of the ray (the enemy's position)
	var from = global_transform.origin

	# Define the ending point of the ray 1 unit below the enemy (adjust distance as needed)
	var to = from - Vector3(0, 41, 0)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	# Perform the raycast and store the result, which will contain info about what the ray hit
	result = space_state.intersect_ray(query)
#	collision_normal = result.normal
	#var collision_info = result.get_collision_info()
	for key in result.keys():
		print(str(key) + ": " + str(result[key]))
	#print(result.rotation_degrees)
	# Check if the ray hit something (e.g., the floor)
	if result:
		

		# Create an instance of the decal scene
		#top_level = true
		decal_instance = decal_scene.instantiate()

	
		
		decal_instance.global_transform.origin = result.position
		
		
		
#		decal_instance.rotate_x(deg_to_rad(180))
		
		# vanhat paske koodit jotka teke basiksel
		var forward_dir = -result.normal.cross(Vector3.UP).normalized()
		var right_dir = forward_dir.cross(result.normal).normalized()
		var basis = Basis(right_dir, result.normal, forward_dir)
		decal_instance.global_transform.basis = basis
		decal_instance.global_transform.origin = result.position + result.normal * 0.2
		get_parent().add_child(decal_instance)
		# Add the decal instance to the scene tree, making it visible in the scene
		
	queue_free()
		# Continue with other logic related to the enemy's death, such as removing the enemy from the scene
