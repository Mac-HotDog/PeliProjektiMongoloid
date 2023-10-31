extends Node3D

var idm
signal painettu( idm)

func _ready():
	idm = self.get_instance_id()
	print(idm)

func _on_area_3d_body_entered(body):
	emit_signal("painettu", idm)
