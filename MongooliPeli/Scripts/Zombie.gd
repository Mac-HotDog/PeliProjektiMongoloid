extends Entity

var player_o_pos
var player = null
var state_machine
var timer
#var level = 1

const SPEED = 3.0
const ATTACK_RANGE = 2.0

#player dmg sources
var bullet = "Area3Dbulletprojectile"


#@export var player_path : NodePath
@export var player_path := "/root/level1/Mannekiini"

#@export var player_path := "res://Scenes/Others/Player.tscn"

@onready var nav_agent = $NavigationAgent3DZombie
@onready var anim_tree = $AnimationTree
@onready var bar = $HealthBar3D/SubViewport/HealthBar2D
@onready var manaBar = $ManaBar3D/SubViewport/ManaBar2D
@onready var particles = $GPUParticles3D
@onready var death_sound = $audiodeath

#@export var player_path =  "/root/level1/Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	player_o_pos = player.global_position
	
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.timeout.connect(_on_timer_timeout)
	

# Called every frame. 'delta' is the elapsed+ time since the previous frame.
func _process(delta):

	if bar:
		bar.update_bar(health)

#	if manaBar:
#		manaBar.update_bar(mana)

		

	if manaBar:
		manaBar.update_bar(mana)

	velocity = Vector3.ZERO

		# Conditions
	anim_tree.set("parameters/conditions/die",die())
	if die() == true:
		#death_sound.play()# ei toimi??

		$HealthBar3D.visible = false
		$ManaBar3D.visible = false
		$Area3DZombie/CollisionShape3D2.disabled = true
		await get_tree().create_timer(5).timeout
		queue_free()

	anim_tree.set("parameters/conditions/attack", _target_in_range())

	anim_tree.set("parameters/conditions/run", _target_not_in_range())
	
	
	match state_machine.get_current_node():
		"GetUp":
			look_at(Vector3(player_o_pos[0], global_position.y, player_o_pos[2]), Vector3.UP)
		"Run":
			# Navigation
			if _target_not_in_range():
				#print(self.global_rotation)

				nav_agent.set_target_position(player.global_transform.origin)
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			
				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
			
		"Attack":

			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)




	#print("Current animation: ", state_machine.get_current_node())
#	print("Attack parameter: ", anim_tree.get("parameters/conditions/attack"))
#	print("Run parameter: ", anim_tree.get("parameters/conditions/run"))
#	print("Player: ", player)
	
	move_and_slide()
	

func _target_in_range():

	var x = global_position.distance_to(player.global_position) < ATTACK_RANGE


	return x
	
	
func _target_not_in_range():
	var x = global_position.distance_to(player.global_position) > ATTACK_RANGE

	return x

	
	
#tällä saadaan melee osumisen tieto
func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 0.5:
		#var dir = global_position.direction_to(player.global_position)
		var melee = true
		player.hit(melee)




func _on_area_3d_area_entered(area):
	if area:
		#health += -15
		#timer.start()
		change_health(-15)

		

func _on_area_3d_area_exited(area):
	timer.stop()

func _on_timer_timeout():
	health += -5
