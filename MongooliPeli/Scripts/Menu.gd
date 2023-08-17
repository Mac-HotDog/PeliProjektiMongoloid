extends Control

#var scene = preload("res://Scenes/Levels/main.tscn")


func _on_button_button_down():
	
	get_tree().change_scene_to_file("res://Scenes/Levels/LevelTest.tscn")


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
