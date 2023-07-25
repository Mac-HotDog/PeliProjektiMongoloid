extends Entity


var player = null
var state_machine
var timer

const SPEED = 4.0
const ATTACK_RANGE = 2.0

#@export var player_path : NodePath

#@export var player_path := "res://Scenes/Others/Player.tscn"
@onready var nav_agent = $NavigationAgent3DZombie
@onready var anim_tree = $AnimationTree
@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@export var player_path =  "/root/Main/Player"


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.timeout.connect(_on_timer_timeout)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bar:
		bar.update_bar(health)
	if manaBar:
		manaBar.update_bar(mana)
		
	velocity = Vector3.ZERO
	
		# Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())

	anim_tree.set("parameters/conditions/run", _target_not_in_range())
	
	
	match state_machine.get_current_node():
		"Run":
			# Navigation
			if _target_not_in_range():
				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			
				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
			
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)



	print("Current animation: ", state_machine.get_current_node())
	print("Attack parameter: ", anim_tree.get("parameters/conditions/attack"))
	print("Run parameter: ", anim_tree.get("parameters/conditions/run"))
	print("Player: ", player)
	move_and_slide()
	

func _target_in_range():
	
	var x = self.global_position.distance_to(player.global_position) < ATTACK_RANGE

	return x
	
	
func _target_not_in_range():
	var x = global_position.distance_to(player.global_position) > ATTACK_RANGE

	return x

	
	
#tällä saadaan osumisen tieto
#func _hit_finished():
#	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
#		var dir = global_position.direction_to(player.global_position)
#		#player.hit(dir)




func _on_area_3d_area_entered(area):
	if area:
		health += -15
		timer.start()
		

func _on_area_3d_area_exited(area):
	timer.stop()
	
func _on_timer_timeout():
	health += -5
