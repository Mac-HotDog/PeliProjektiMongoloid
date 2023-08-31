extends Node3D

@onready var audio = $AudioStreamPlayer3D
var dmg = 5
var target

func _ready():
	audio.play()
	await get_tree().create_timer(4).timeout
	queue_free()

#func _physics_process(delta):
#	if target != null:
#		deal_dmg()

#func deal_dmg():
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#	await get_tree().create_timer(0.5).timeout
#	target.change_health(-dmg)
#
#func _on_area_3d_area_entered(area):
#	if area.get_parent() is Enemy:
#		target = area.get_parent()
#		deal_dmg()
