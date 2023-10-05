extends Node3D

@onready var dildo = $dildo

func _on_area_3d_body_entered(body):
	var ryhmat = body.get_groups()
	for x in ryhmat:
		if x == "player":
			await get_tree().create_timer(1.0).timeout
			dildo.show()
			dildo.set_process(true)
			await get_tree().create_timer(2.0).timeout
			dildo.hide()
			dildo.set_process(false)
