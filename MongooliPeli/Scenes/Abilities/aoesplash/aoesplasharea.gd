extends Node3D

var dmg = 1
var enemy

func _ready():
	await get_tree().create_timer(4).timeout
	queue_free()

func _physics_process(delta):
	if enemy != null:
		enemy.change_heealth(dmg)


func _on_area_3d_area_entered(area):
	if area is Enemy:
		print("osui")
		enemy = area.get_parent()
