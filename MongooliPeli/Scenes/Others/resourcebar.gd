extends Sprite3D
@onready var control = $SubViewport/Control
@onready var bar = $SubViewport/Control/ProgressBar
@onready var viewport = $SubViewport
@onready var parent = get_parent()
var value = 100



func _ready():
	viewport.set_update_mode(SubViewport.UPDATE_WHEN_PARENT_VISIBLE)
	global_position = parent.global_position
	bar.value = 100
	var tween = get_tree().create_tween()
	tween.tween_property(bar,"value", 100,3).set_trans(Tween.TRANS_LINEAR)
	

func update_bar(x):#x on hp määrä
	bar.value = x

func _physics_process(delta):
	#bar.global_tra = port.global_canvas_transform
	#self.global_position = parent.global_position
#	bar.global_position.y = self.global_position.y
#	bar.global_position.x = self.global_position.x
	pass
