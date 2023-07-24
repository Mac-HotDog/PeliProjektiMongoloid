extends Node3D

var laskin = 0

func _on_timer_timeout():
	
	if laskin == 0:
		laskin +=1
		hide()
	else:
		laskin += -1
		show()
