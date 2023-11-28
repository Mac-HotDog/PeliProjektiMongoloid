extends Node3D

@onready var zombi = preload("res://Scenes/Levels/Others/Zombie.tscn")
var zombiIns
@export var numberOfZombies: int
@onready var spawn_light = $SpotLight3D


func _on_area_3d_body_entered(body):
	if body.get_groups().size() > 0:
		if "player" == body.get_groups()[0] :
			#and numberOfZombies > 0
			#print("pelaaja tunnistettu")
			top_level = true
			zombiIns = zombi.instantiate()
			add_child(zombiIns)
			spawn_light.visible = true
			$spawnaudio.play()
			await get_tree().create_timer(30).timeout
			spawn_light.visible = false
			#numberOfZombies -= 1
			#queue_free()