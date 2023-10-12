extends Node3D

@onready var dildo = $dildo
@onready var area = $dildo/Area3D
@onready var coll = $dildo/Area3D/CollisionShape3D
@onready var triggerSound = $click

func _on_area_3d_body_entered(body):
	var ryhmat = body.get_groups()
	for x in ryhmat:
		if x == "player":
			triggerSound.play()
			await get_tree().create_timer(1.0).timeout
			dildo.show()
			area.set_monitorable(true)
			area.set_monitoring(false)
			area.set_monitoring(true)
			await get_tree().create_timer(2.0).timeout
			dildo.hide()
			area.set_monitorable(false)
