extends Control
@onready var tooltip = $Control/Tooltip
@onready var ttcontrol = $Control
@export var stat_type = "attack damage"
@export var stat_value = 15

func _ready():
	pass

func cost():
	return 30

func name_returner():
	return "dagger"

func stat_and_value_returner(query):
	if query == "stat":
		return stat_type
	if query == "value":
		return stat_value

