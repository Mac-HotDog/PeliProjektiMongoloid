extends CharacterBody3D

class_name Entity

var health: int = 5
var mana: int = 100
var strength: int = 10
var agility: int = 10
var intelligence: int = 10

var health_regen: int = 1  # Health regenerated per second
var mana_regen: int = 1  # Mana regenerated per second

var _regen_timer: float = 0  # Timer to keep track of regeneration interval

# Basic stat modifying functions
func change_health(value: int) -> void:
	self.health += value
	if self.health <= 0:
		die()

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
func die() -> void:
	print(str(self) + " has died.")  # placeholder, replace with actual functionality

# Called every physics frame
func _physics_process(delta: float) -> void:
	self._regen_timer += delta
	if self._regen_timer >= 1.0:
		print(self.health)
		self._regen_timer -= 1.0
		regenerate_health()
		regenerate_mana()
		
func load_ability(name):
	var scene = ResourceLoader.load("res://Scenes/Abilities/" + name + "/" + name + ".tscn")
	var d = scene.instantiate()
	add_child(d)
	return d