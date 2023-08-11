extends Camera3D

var marginH = 1000
var marginNH = -1000
var marginW = 1800
var marginNW = -1800
var margin = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	
	var mouse_pos = get_viewport().get_mouse_position()
	var window_size = get_viewport().get_size()
	
#	if mouse_pos.x <= margin:
#		self.transform.origin += Vector3(-0.01, 0, 0) 
#		#print("Mouse is touching the left side of the screen.")
#	elif mouse_pos.x >= window_size.x - margin:
#		self.transform.origin += Vector3(0.01, 0, 0) 
#		#print("Mouse is touching the right side of the screen.")
#	if mouse_pos.y <= margin:
#		self.transform.origin += Vector3(0, 0, -0.01) 
#		#print("Mouse is touching the top of the screen.")
#	elif mouse_pos.y >= window_size.y - margin:
#		self.transform.origin += Vector3(0, 0, 0.01) 
#		#print("Mouse is touching the bottom of the screen.")
#
#


