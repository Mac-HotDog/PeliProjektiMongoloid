extends MeshInstance3D

@onready var lava_particle = $GPUParticles3D

func _ready():
	var x = randf()
	lava_particle.lifetime = x
	
