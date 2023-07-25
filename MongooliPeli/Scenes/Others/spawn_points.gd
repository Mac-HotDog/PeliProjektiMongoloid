extends Node3D

@onready var zombi = preload("res://Scenes/Others/Zombie.tscn")
var zombiIns




func _on_area_3d_body_entered(body):
	print(body.get_groups()[0])
	if "player" == body.get_groups()[0]:
		print("pelaaja tunnistettu")
		top_level = true
		zombiIns = zombi.instantiate()
		add_child(zombiIns)
		#queue_free()
