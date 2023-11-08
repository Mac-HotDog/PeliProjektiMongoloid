extends Enemy
#vissiin vaan tällä toimii hp regen toistaseks

#var player = null
var player_pos #viiveellinen pelaajn sijainti
#var allow_getting_pos = false #lippu pelaaja posille
var dead = false
var last_hitter #kuka teki dmg vikana
#var SPEED = 4.0
var ATTACK_RANGE = 1.4
@export var gold_value = 200
@export var exp_value = 150
@export var flame_dmg = 55 #tämänkin pitäs varmaan olla dot
@export var punch_combo_dmg = 20 # per tick, 0.5s
@export var dash_move_dmg = 40

#@export var player_path : NodePath
#@export var player_path := "/root/level1/Mannekiini"
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
@onready var punchcomboaudio = $audio/punchcombo

var allow_idle
var casting_animation = ["powerup","ultimate","jump","jumpdown","punchcombo","death","knocked"]
var activeanimationplaying
var animplaying
#var moveplaying = false


#skills
@onready var timer = $Timer# ei tee vielä mitään
@onready var flame_marker = $Marker3D #mistä liekit tulee
var flame = load_ability("flame")
@onready var punch_combo_area = $Area3DPunchCombo/CollisionShape3D
var in_punch_combo_area = false
#dashia
@export var  DASH_DISTANCE = 5
var dash_collision #move_and_collide()
var original_pos
var current_pos
var dash_direction = Vector3.FORWARD
var is_dashing = false
var took_dash_dmg = false # lippu pelaajaa varten


#counters, ei tee vielä mtn
var dashcounter = 0
var punchcombocounter = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	punch_combo_area.disabled = true
	#timer.start()
	health += 200
	SPEED = 4.5
	anim_player.set_speed_scale(2)
	player = get_node(player_path)
	play_animation("jumpdown",true)
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
			anim_player.set_speed_scale(2)
			anim_player.play(animation)
			look_at(player.global_position,Vector3.UP,true)
		if animation == "ultimate":
			anim_player.play(animation)
			await get_tree().create_timer(1.1).timeout
			anim_player.set_speed_scale(0.7)
			await get_tree().create_timer(1.5).timeout
			anim_player.set_speed_scale(2)
		if animation == "death":
			anim_player.set_speed_scale(1.8)
			anim_player.play(animation)
		if animation == "knocked":
			anim_player.stop()
			anim_player.set_speed_scale(1)
			anim_player.play(animation)
		if animation == "jumpdown":
			anim_player.play(animation)
			velocity.y = -8
		else:
			anim_player.set_speed_scale(2)
			anim_player.play(animation)
			
func whendead():
	$OmniLight3D.visible = false
	if punchcomboaudio.is_playing():
		punchcomboaudio.stop()
	is_dashing = false
	dead = true
	deathaudio.play()
	play_animation("death",true)
	last_hitter.change_gold(gold_value)
	last_hitter.change_exp(exp_value)
	flame.end_flame()
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
	if knockback and knockback_reset:
		knockback_reset = false
		knocked_back_func()

	animplaying = anim_player.get_current_animation()
	activeanimationplaying = casting_animation.has(animplaying)
	if activeanimationplaying or is_dashing: #or moveplaying:
		nav_agent.set_target_position(self.global_position)


		
	if bar:
		bar.global_position = self.global_position
		bar.global_position[1] = self.global_position[1] + 2
		bar.update_bar(health)

#	if not is_on_floor():
#		print("notonfloor")
#		velocity.y = 9 * delta
#	if is_on_floor():
#		print("onfloor")
	if animplaying != "jumpdown":
		velocity = Vector3.ZERO#?

	

	
	if _target_in_range() and not activeanimationplaying and not stunned:
		#if !moveplaying:
		move_decider()
		
	if is_dashing: #vois varmaan laittaa funktioon vaa
		dash_direction = transform.basis.z.normalized()
		var dash_vector = dash_direction * DASH_DISTANCE
		current_pos = self.global_position
		if original_pos.distance_to(current_pos) >= DASH_DISTANCE:
			is_dashing = false
			dash_collision = null
		dash_collision = move_and_collide(dash_vector * delta * 1.2)#,false,0.001,false,40)
#		if stunned:
#			return
		
		if dash_collision and took_dash_dmg == false:
			#print(collision.get_collider())
			if dash_collision.get_collider() == player:
				took_dash_dmg = true
				player.change_health(-dash_move_dmg)
				dash_collision = null#move_and_collide(Vector3.ZERO)
				is_dashing = false
			
	

	if _target_not_in_range() and not activeanimationplaying: #and not moveplaying and not activeanimationplaying:
		move_and_run()

	if not is_dashing:
		move_and_slide()

func move_and_run():
	if not activeanimationplaying and not die() and not stunned:
		#marker.look_at(player.global_position,Vector3.UP)
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
		#rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		var kohta = Vector3(player.global_position.x, global_position.y, player.global_position.z)
		look_at(next_nav_point,Vector3.UP,true)
		play_animation("run",true)
		#move_and_slide()

func knocked_back_func():
	if knockback:
		play_animation("knocked",true)
		look_at(player.global_position,Vector3.UP,true)
		is_dashing = false
		$OmniLight3D.visible = false
		punchcomboaudio.stop()
		dash_collision = null
		flameaudio.stop()
		flame.end_flame()

func move_decider():
	#if timer.time_left <= 0.1:# ei toimi vielä
		#print("perse")
	var x = randf()
	#print(x)
	if x <= 0.60:
		punch_combo()
	if x > 0.60 and x < 0.80:
		flame_move()
	if x >= 0.8:
		dash_move()
		


func punch_combo():
	if not stunned and not dead:
		punchcombocounter += 1
		punchcomboaudio.play()
		look_at(player.global_position,Vector3.UP,true)
		play_animation("punchcombo", true)

	
func punch_combo_animation_moment():#lyöntien hetket
	punch_combo_area.disabled = false
	await get_tree().create_timer(0.1).timeout
	punch_combo_area.disabled = true
	
func punch_combo_end(): #ei koko animaation loppu, vain lyömisen
	punchcomboaudio.stop()
	
func dash_move():
	if not stunned and not dead:
		original_pos = self.global_position# saadaan opos jolla rajoteitaan dash rangee
		took_dash_dmg = false #pelaajan vahinkoa varten
		roaraudio.play()
		dash_move_indicator()	
		await get_tree().create_timer(1).timeout
		play_animation("jump", true)
		is_dashing = true #menee physprosessiin

	
func dash_move_indicator():
	$OmniLight3D.visible = true
	play_animation("powerup",true)


func dash_animation_end():
	$OmniLight3D.visible = false
	is_dashing = false
	dash_collision = null
	
	
func flame_move():
	#moveplaying = true
	play_animation("ultimate",true)

func ultimate_animation_moment():#liekki spelli
	flame.marker_getter(flame_marker)#antaa marker noden ja siitä saa spawn pos
	flame.execute(self)
	flameaudio.play()
	await get_tree().create_timer(1).timeout
	flameaudio.stop()

func ultimate_animation_end():#animaatiohetki
	flame.end_flame()#despawnaa liekin
	#await get_tree().create_timer(0.5).timeout
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
	if area.get_parent() is kick:
		change_health(-player.kick_dmg_returner())
	if area is aoeslow:
		take_dot()
		SPEED = 2
		

func _on_area_3d_area_exited(area):
	if area is aoeslow:
		SPEED = 4.5


func _on_area_3d_punch_combo_area_entered(area):
	if area.get_parent() is Entity or area is Entity:
		punch_combo_dmg_sender()
		print("osui")

#func _on_area_3d_punch_combo_area_exited(area):
#	if area.get_parent() is Entity or area is Entity:
#		in_punch_combo_area = false
#		print("ei lyönti")
#		punch_combo_dmg_sender(false)#turha

func punch_combo_dmg_sender():
	player.change_health(-punch_combo_dmg)
