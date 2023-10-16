extends Enemy
#vissiin vaan tällä toimii hp regen toistaseks

var player = null
var player_pos #viiveellinen pelaajn sijainti
#var allow_getting_pos = false #lippu pelaaja posille
var dead = false
var last_hitter #kuka teki dmg vikana
var SPEED = 4.0
var ATTACK_RANGE = 1.4
@export var gold_value = 200
@export var exp_value = 150
@export var flame_dmg = 50

#@export var player_path : NodePath
@export var player_path := "/root/level1/Mannekiini"
@onready var marker = get_parent()
@onready var armature = $Armature
@onready var nav_agent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var bar = $Resourcebar
@onready var dash_timer = $TimerDash
@export var dmg_number_scene = preload("res://Scenes/Others/dmg_number.tscn")
var dmg_number

#audio
@onready var impactaudio = $audio/impact
@onready var flameaudio = $audio/flamespell
@onready var deathaudio = $audio/death
@onready var roaraudio = $audio/powerup
@onready var yellaudio = $audio/yell

var allow_idle
var casting_animation = ["powerup","ultimate","jumpmove","jumpdown","punchcombo","death"]
var activeanimationplaying
var animplaying
var moveplaying = false

#skills
@onready var timer = $Timer
@onready var flame_marker = $Marker3D
var flame = load_ability("flame")
#dashia
@export var  DASH_DISTANCE = 3
var original_pos
var current_pos
var dash_direction = Vector3.FORWARD
var is_dashing = false
var dash_progress = 0.0

#counters
var dashcounter = 0
var punchcombocounter = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()
	health += 200
	anim_player.set_speed_scale(2)
	player = get_node(player_path)
	anim_player.play("jumpdown")
	yellaudio.play()


func play_animation(animation,condition):
	if condition:
		if animation == "run":
			allow_idle = false
			anim_player.set_speed_scale(2)
			anim_player.play(animation)
		if animation == "death":
			anim_player.stop()
			allow_idle = false
			anim_player.set_speed_scale(2)
			anim_player.play(animation)
		if animation == "powerup":
			anim_player.play(animation)
			look_at(player.global_position)
		if animation == "ultimate":
			anim_player.play(animation)
			await get_tree().create_timer(1.1).timeout
			anim_player.set_speed_scale(0.7)
			await get_tree().create_timer(1.5).timeout
			anim_player.set_speed_scale(2)
		else:
			anim_player.play(animation)
			
func whendead():
	dead = true
	deathaudio.play()
	play_animation("death",true)
	last_hitter.change_gold(gold_value)
	last_hitter.change_exp(exp_value)
	#last_hitter.target_killed()
	deathaudio.play()
	$Area3D/CollisionShape3D.disabled = true
	bar.visible = false
	await get_tree().create_timer(5).timeout
	queue_free()

func change_health(value):
	dmg_number = dmg_number_scene.instantiate()
	add_child(dmg_number)#sqpawnaa ja deletoid koko ajan, vie varmaa tehoja
	dmg_number.add_dmg_numbers(str(value), self.global_position,1,1)
	health += value
	
func gold_value_returner():
	return gold_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if die() == true and dead == false:
		whendead()
	
	animplaying = anim_player.get_current_animation()
	activeanimationplaying = casting_animation.has(animplaying)
	#print(health)
	if bar:
		bar.global_position = self.global_position
		bar.global_position[1] = 3.5
		bar.update_bar(health)

#	if not is_on_floor():
#		velocity.y = 9 * delta
	velocity = Vector3.ZERO#?
	
	
	if activeanimationplaying or moveplaying:
		nav_agent.set_target_position(self.global_position)
	
	
	if _target_not_in_range(): #and not moveplaying and not activeanimationplaying:
		move_and_run()

	
	if _target_in_range() and not activeanimationplaying:
		#if !moveplaying:
		move_decider()
		
	if is_dashing:
		#nav_agent.set_target_position(self.global_position)
		dash_direction = -transform.basis.z.normalized()
		dashcounter += 1
		var dash_vector = dash_direction * DASH_DISTANCE
		current_pos = self.global_position
		if original_pos.distance_to(current_pos) >= DASH_DISTANCE:
			is_dashing = false
		
		move_and_collide(dash_vector * delta)
		
	#print(moveplaying)
	
	move_and_slide()
	
#	allow_run = not navigationAgent.is_navigation_finished()
#	activeanimationplaying = activeanimations.has(animplaying)


func move_and_run():
	if not activeanimationplaying and not moveplaying:
		#marker.look_at(player.global_position,Vector3.UP)
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
		#rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(player.global_position,Vector3.UP)#,true)
		play_animation("run",true)
		

func move_decider():
	if timer.time_left <= 0.1:
		print("perse")
	var x = randf()
	flame_move()
#	if x <= 0.33:
#		punch_combo()
#	if x > 0.33 and x < 0.66:
#		flame_move()
#	else:
#		dash_move_indicator()
#		roaraudio.play()
#		dash_move()
#		original_pos = self.global_position# rajoteitaan dash rangee

func flame_move():
	#moveplaying = true
	play_animation("ultimate",true)

func punch_combo():
	#moveplaying = true
	punchcombocounter += 1
	look_at(player.global_position,Vector3.UP)
	play_animation("punchcombo", true)
	await get_tree().create_timer(2).timeout#scuffed
	#moveplaying = false

func dash_move():
	#moveplaying = true
	await get_tree().create_timer(1).timeout
	play_animation("jumpmove", true)
	is_dashing = true #menee physprosessiin

	
func dash_move_indicator():
	$OmniLight3D.visible = true
	play_animation("powerup",true)


func dash_animation_end():
	$OmniLight3D.visible = false
	#await get_tree().create_timer(2).timeout#scuffed
	#moveplaying = false
	is_dashing = false
	
func jumpdown_animation_end():
	pass
	
func ultimate_animation_moment():#liekki spelli
	flameaudio.play()
	flame.marker_position(flame_marker)#antaa marker noden ja siitä saa spawn pos
	flame.execute(self)

func ultimate_animation_end():
	flame.end_flame()#despawnaa liekin
	await get_tree().create_timer(0.5).timeout
	#moveplaying = false


func _target_in_range():
	var x = global_position.distance_to(player.global_position) < ATTACK_RANGE
	return x
	
func _target_not_in_range():
	var x = global_position.distance_to(player.global_position) > ATTACK_RANGE
	return x
	
#func allow_getting_pos():
#	pass


#tällä saadaan melee osumisen tieto
#func _hit_finished():
#	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 0.5:
#		#var dir = global_position.direction_to(player.global_position)
#		var melee = true
#		player.hit(melee)

func take_dot():
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())
	await get_tree().create_timer(0.5).timeout
	change_health(-player.aoeslow_dmg_returner())


func _on_area_3d_area_entered(area):
#	if area:
#		#health += -15
#		timer.start()
#		#print(area)
#		change_health(-15)
	var area_source = area.get_parent()
	var spawner_source = area_source.get_parent()
	if spawner_source.get_parent() is Entity:
		last_hitter = spawner_source.get_parent()
	if area is autoattack or area.get_parent() is autoattack:
		impactaudio.play()
		change_health(-player.aa_dmg_returner())
	if area is bullet or area.get_parent() is bullet:
		change_health(-player.bullet_dmg_returner())
		#print(area.class)
	if area is aoeslow:
		take_dot()
		SPEED = 2
		

func _on_area_3d_area_exited(area):
	if area is aoeslow:
		SPEED = 4
	




