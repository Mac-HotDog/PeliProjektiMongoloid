extends CharacterBody3D

class_name Entity

var level = 1
var exp = 0
var health: int = 100 + 20 * level
var mana: int = 100
var strength: int = 10
var agility: int = 10
var intelligence: int = 10
#var attack_damage = 10
var gold = 0 #current gold
var item_list = []
#@onready var inventoryscene = preload("res://Scenes/inventory.tscn")
#var inventory

var health_regen: int = 1  # Health regenerated per second
var mana_regen: int = 1  # Mana regenerated per second

var _regen_timer: float = 0  # Timer to keep track of regeneration interval

#func _on_ready():
#	inventory = inventoryscene.instantiate()
#	add_child(inventory)

#func change_gold(value):
#	gold += value
#	if inventory != null:
#		inventory.change_gold(gold)
#		print(gold)
	
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
	self.health = min(self.health + self.health_regen, 100)

func regenerate_mana() -> void:
	self.mana = min(self.mana + self.mana_regen, 100)

# Function to be called when an entity dies

func die():
	if health <= 0:
		return true
	else:
		return false
	

# Called every physics frame
func _physics_process(delta: float) -> void:
	die()
	self._regen_timer += delta
	if self._regen_timer >= 1.0:
		#print(self.health)
		self._regen_timer -= 1.0
		regenerate_health()
		regenerate_mana()
		
func load_ability(name):
	var scene = ResourceLoader.load("res://Scenes/Abilities/" + name + "/" + name + ".tscn")
	var d = scene.instantiate()

	add_child(d)
	return d

