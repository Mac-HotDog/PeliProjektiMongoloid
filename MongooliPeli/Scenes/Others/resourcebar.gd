extends Sprite3D
@onready var control = $SubViewport/Control
@onready var bar = $SubViewport/Control/ProgressBar
@onready var viewport = $SubViewport
@onready var label = $SubViewport/Control2/Label
@onready var level_srite = $Level
@onready var lvl_viewport = $Level/SubViewport2
@onready var lvl_label = $Level/SubViewport2/Control/LevelLabel
@onready var parent = get_parent()
var value = 100
var max_value_gotten = false


func _ready():
	lvl_viewport.set_update_mode(SubViewport.UPDATE_WHEN_PARENT_VISIBLE)
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
#	var tween = get_tree().create_tween()
#	tween.tween_property(bar,"value", 100,3).set_trans(Tween.TRANS_LINEAR)# ei taida toimia


func _physics_process(delta):
	level_srite.global_position[0] = self.global_position[0] -1
	level_srite.global_position[1] = self.global_position[1]
	level_srite.global_position[2] = self.global_position[2]
	
func update_bar(x):#x on tämän hetken hp määrä
	if !max_value_gotten:
		bar.max_value = x
		max_value_gotten = true
	bar.value = x
	label.text =str(x)#scuffed ik # "                  "+

func update_level(x):
	lvl_label.text = str(x)
