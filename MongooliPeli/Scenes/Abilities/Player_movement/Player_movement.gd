#extends Node
#
#func execute(node, target):
#	if target:
#		look_at(target, Vector3.UP)
#		rotation.x = 0
#		velocity = -transform.basis.z * speed
#		if transform.origin.distance_to(target) < .5:
#			target = Vector3.ZERO
#			velocity = Vector3.ZERO
