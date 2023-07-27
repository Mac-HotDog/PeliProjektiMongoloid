extends Control

#var scene = preload("res://Scenes/Levels/main.tscn")


func _on_button_button_down():
	
	get_tree().change_scene_to_file("res://Scenes/Levels/level1.tscn")
