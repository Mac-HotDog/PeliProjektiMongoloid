extends Node3D

# Threshold distance from the edge
const EDGE_THRESHOLD = 50

const CAMERA_MOVE_SPEED = 0.1

const CAMERA_ZOOM_SPEED = 0.4



@onready var camera_o_pos = $Camera3D.position
@onready var player_o_pos = $Mannekiini.position

func _ready():
	var audioplayer = $AudioStreamPlayer
	#audioplayer.
	

			
func _input(event):
	if Input.is_action_just_pressed("RightMouse"):
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
		if result.position.y < 0:
			result.position.y = 0.3

		$Marker.visible = true         
		$Marker.transform.origin = result.position
		await get_tree().create_timer(1).timeout
		$Marker.visible = false 





# Threshold distance from the edge
const EDGE_THRESHOLD = 50




func _on_mouse_near_edge(edge):
	var camera = $Camera3D
	
	
	if edge == "left":

		move_camera(-CAMERA_MOVE_SPEED, 0, 0)
		#print("Mouse near left edge")
	if edge == "right":

		move_camera(CAMERA_MOVE_SPEED, 0, 0)
		#print("Mouse near right edge")
	if edge == "top":

		move_camera(0,0,-CAMERA_MOVE_SPEED)
		#print("Mouse near top edge")
	if edge == "bottom":

		move_camera(0,0,CAMERA_MOVE_SPEED)
		#print("Mouse near bottom edge")
		


func move_camera(x, y, z):
	set_physics_process(true)#koitin saada kamera lagin pois mutta joutuu tekemään enemmän
	var camera = $Camera3D
	var new_origin = camera.transform.origin + Vector3(x, y, z)
	camera.transform.origin = new_origin
	#print("kameran saama ",new_origin)
	


func _physics_process(delta):
	var camera_pos = $Camera3D.global_position
	var player_pos = $Mannekiini.global_position
	var difference = camera_o_pos[2] - player_o_pos[2]
	var z = player_pos[2] + difference
	var new_camera_pos = Vector3(player_pos[0],camera_pos[1],z)
	if Input.is_action_just_pressed("space") or Input.is_action_pressed("space"):
		$Camera3D.transform.origin = new_camera_pos

	if Input.is_action_just_released("ZoomOut"): 
		#zoomaa (epätarkka, käyttää samaa nopeutta ja toimii vain y ja z)
		move_camera(0,CAMERA_ZOOM_SPEED,CAMERA_ZOOM_SPEED)
	
	if Input.is_action_just_released("ZoomIn"):
		
		move_camera(0,-CAMERA_ZOOM_SPEED,-CAMERA_ZOOM_SPEED) 
	
	if NOTIFICATION_VP_MOUSE_ENTER:
		# Get the mouse position
		var mouse_pos = get_viewport().get_mouse_position()
		var viewport_size = get_viewport().size

		# Calculate the distance from the mouse position to the edges
		var distance_left = mouse_pos.x
		var distance_right = viewport_size.x - mouse_pos.x
		var distance_top = mouse_pos.y
		var distance_bottom = viewport_size.y - mouse_pos.y

		# Check if the mouse is near any edge and emit the signal

		if distance_left < EDGE_THRESHOLD:
			_on_mouse_near_edge("left")
		if distance_right < EDGE_THRESHOLD:
			_on_mouse_near_edge("right")
		if distance_top < EDGE_THRESHOLD:
			_on_mouse_near_edge("top")
		if distance_bottom < EDGE_THRESHOLD:
			_on_mouse_near_edge("bottom")
