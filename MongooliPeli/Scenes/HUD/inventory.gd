extends Node2D
@onready var gold_display = $Control/Gold
var gold = 0

func change_gold(value):
	gold += value
	gold_display.text = str(gold)
	
#func gold_returner():
#	return gold

func add_item_to_inventory(item):
	if $GridContainer/Slot1.get_child(0) == null:
		var instance = item.instantiate()
		$GridContainer/Slot1.add_child(instance)
