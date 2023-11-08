extends Node
var parent


func _ready():
	$Area3D/CollisionShape3D.disabled = true
	await get_tree().create_timer(0.1)
	$Area3D/CollisionShape3D.disabled = false
	$Area3D/CollisionShape3D2.disabled = true
	await get_tree().create_timer(0.3).timeout
	$Area3D/CollisionShape3D2.disabled = false

func get_parent_func(x):
	parent = x

func _on_area_3d_area_entered(area):
	if area is Entity or area.get_parent() is Entity:
		parent.flame_dmg_sender()
