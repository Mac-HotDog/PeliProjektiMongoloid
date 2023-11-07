extends CharacterBody3D

class_name Enemy

 #= null
var player_path := "/root/level1/Mannekiini"#level1
@onready var player = get_node(player_path)
var health: int = 100
var mana: int = 100
var strength: int = 10
var agility: int = 10
var intelligence: int = 10
var SPEED 

var health_regen: int = 1  # Health regenerated per second
var mana_regen: int = 1  # Mana regenerated per second

var _regen_timer: float = 0  # Timer to keep track of regeneration interval

var knockback = false#lippu move and collide ja animaatiolle
var knockback_reset = true # lippu physprosessia varten?? templarille
var kicked_back = false #lippu kick collision dmg
var knockback_vector
var stunned = false #lippu lukolle

# Basic stat modifying functions
func change_health(value: int) -> void:
	self.health += value
	#print(self," current health:",health)


func change_mana(value: int) -> void:
	self.mana += value

func change_strength(value: int) -> void:
	self.strength += value

func change_agility(value: int) -> void:
	self.agility += value

func change_intelligence(value: int) -> void:
	self.intelligence += value

# Health and mana regen functions
func regenerate_health() -> void:
	self.health = min(self.health + self.health_regen, health)

func regenerate_mana() -> void:
	self.mana = min(self.mana + self.mana_regen, 100)

# Function to be called when an entity dies

func die():
	if health <= 0:
		return true
	else:
		return false
		
func kicked(cc_duration): #cc_dur on vain stun dur eikä move_and_colliden
	knockback = true
	knockback_reset = true#physprosessia varten
	stunned = true
	knockback_vector = (self.global_position - player.global_position)
	knockback_vector[1] = 0
	knockback_vector = knockback_vector.normalized() * 3
	await get_tree().create_timer(cc_duration).timeout 
	stunned = false
	knockback = false
	#SPEED = 4
	

# Called every physics frame
func _physics_process(delta: float) -> void:
	die()
	self._regen_timer += delta
	if self._regen_timer >= 1.0:
		#print(self.health)
		self._regen_timer -= 1.0
		regenerate_health()
		regenerate_mana()
	if knockback:
		#velocity 
		var collision = move_and_collide(knockback_vector * delta * 2)
		if collision:
			var collateral = collision.get_collider()
			if collateral is Enemy:
				collateral.change_health(-player.kick_dmg_returner())
		
func load_ability(name):
	var scene = ResourceLoader.load("res://Scenes/Abilities/" + name + "/" + name + ".tscn")
	var d = scene.instantiate()

	add_child(d)
	return d

