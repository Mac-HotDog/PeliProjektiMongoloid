extends Node

func _ready():
	$Area3D/CollisionShape3D2.disabled = true
	await get_tree().create_timer(0.3).timeout
	$Area3D/CollisionShape3D2.disabled = false



func _on_area_3d_area_entered(area):
	pass # Replace with function body.
