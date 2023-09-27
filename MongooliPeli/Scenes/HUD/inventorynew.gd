extends Control
@onready var gold_display = $Control/Label
var gold = 0
var items = []

func change_gold(value):
	gold += value
	gold_display.text = str(gold)
	
#func gold_returner():
#	return gold

func add_item_to_inventory(item):
	if $GridContainer/slot1.get_child(0) == null:#paska ja nyt lisää kokonaisen skenen lapseksi
		var instance = item.instantiate()
		$GridContainer/slot1.add_child(instance)
		items.append("dagger")

#func check_inventory():
#	return items
