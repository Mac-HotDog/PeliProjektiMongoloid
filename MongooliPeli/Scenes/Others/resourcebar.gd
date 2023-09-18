extends Sprite3D
@onready var control = $SubViewport/Control
@onready var bar = $SubViewport/Control/ProgressBar
@onready var viewport = $SubViewport
@onready var label = $SubViewport/Control2/Label
@onready var parent = get_parent()
var value = 100



func _ready():
	viewport.set_update_mode(SubViewport.UPDATE_WHEN_PARENT_VISIBLE)
	if parent is Enemy:
		var sb = StyleBoxFlat.new()
		bar.add_theme_stylebox_override("fill", sb)
		sb.bg_color = Color("ff0000")
		sb.border_width_bottom = 2
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_color = Color("000000")
	global_position = parent.global_position
	bar.value = 100
	var tween = get_tree().create_tween()
	tween.tween_property(bar,"value", 100,3).set_trans(Tween.TRANS_LINEAR)# ei taida toimia
	

func update_bar(x):#x on tämän hetken hp määrä
	bar.value = x
	label.text =str(x)#scuffed ik # "                  "+

func _physics_process(delta):
	#label.position[0] = global_position[0]
	#label.position[1] = global_position[1]
	#bar.global_tra = port.global_canvas_transform
	#self.global_position = parent.global_position
#	bar.global_position.y = self.global_position.y
#	bar.global_position.x = self.global_position.x
	pass
