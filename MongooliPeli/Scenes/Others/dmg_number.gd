extends Node3D
#class_name DamageNumber2D
#lähes suoraan tutoriaalista
@onready var label = $Node3D/Label3D
@onready var label_container = $Node3D#idea oli että tätä ontrollia animois mutta en osannu
@onready var ap = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#func set_values_and_animate
func add_dmg_numbers(value:String, start_pos:Vector3, height:float, spread:float) -> void:
	start_pos[1] += 1
	label.global_position = start_pos
	label.text = value
	ap.play("Rise and Fade")
	
	var tween = get_tree().create_tween()
	var end_pos = Vector3(randf_range(-spread,spread),height,randf_range(1,2)) + start_pos
	var tween_length = ap.get_animation("Rise and Fade").length
	
	tween.tween_property(label,"global_position",end_pos,tween_length).from(start_pos)


func remove() -> void:
	ap.stop()
	if is_inside_tree():
		get_parent().remove_child(self)
		queue_free()
