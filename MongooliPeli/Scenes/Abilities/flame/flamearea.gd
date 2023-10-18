extends Node3D
class_name Flamethrower

@onready var hitbox2 = $Area3D/CollisionShape3D2

func _ready():
	await get_tree().create_timer(0.5).timeout
	hitbox2.disabled = false

#func cast_direction(dir):
#	$GPUParticles3D.gravity = dir

