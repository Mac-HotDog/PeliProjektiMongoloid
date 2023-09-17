extends Node2D
@onready var gold_display = $Control/Gold
var gold = 0

func change_gold(value):
	gold += value
	gold_display.text = str(gold)
	
#func gold_returner():
#	return gold
