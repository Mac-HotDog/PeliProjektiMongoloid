extends Control


func _on_button_pressed():
	get_tree().paused = false
	hide()

func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)




func _on_button_2_button_down():
	get_tree().paused = false
	var scene = load("res://Scenes/Levels/Menu.tscn")
	var instance = scene.instantiate()

	var scene_tree = get_tree()
	var current_scene = scene_tree.get_current_scene()

	scene_tree.get_root().remove_child(current_scene)
	scene_tree.get_root().add_child(instance)
	scene_tree.set_current_scene(instance)
