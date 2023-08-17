extends Control


func _on_button_pressed():
	get_tree().paused = false
	hide()

func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
