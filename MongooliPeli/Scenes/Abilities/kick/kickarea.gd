extends Node3D
class_name kick

@onready var impactaudio = $impactaudio
var monitoring = true
var hit = false
var cc_duration = 0.8

func disable_area():
	monitoring = false

func _on_area_3d_area_entered(area):
	if monitoring:
		if area.get_parent() is Enemy:
			area.get_parent().kicked(cc_duration)
			impactaudio.play()

#func _physics_process(delta):
#	if hit:
#		targets.move_and_collide(vektori * delta)
