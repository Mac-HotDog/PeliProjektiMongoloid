extends Control
@onready var gold_display = $Control/Label
@onready var slot1 = $GridContainer/slot1
@onready var slot2 = $GridContainer/slot2
@onready var slot3 = $GridContainer/slot3
@onready var slot4 = $GridContainer/slot4
@onready var slot5 = $GridContainer/slot5
@onready var slot6 = $GridContainer/slot6
var gold = 0
var item_names = []
var item_counter = 0
var itemslot1#skenejä tällä hetkellä
var itemslot2
var itemslot3
var itemslot4
var itemslot5
var itemslot6

var attack_damage_amount = 0
var health_amount

func change_gold(value):
	gold += value
	gold_display.text = str(gold)
	
#func gold_returner():
#	return gold

func add_item_to_inventory(item):
	if item_counter == 0:
		var instance = item.instantiate()
		slot1.add_child(instance)
		itemslot1 = instance
		item_counter += 1
		check_stats(itemslot1)
	elif item_counter == 1:
		var instance = item.instantiate()
		slot2.add_child(instance)
		itemslot2 = instance
		item_counter += 1
		check_stats(instance)
	elif item_counter == 2:
		var instance = item.instantiate()
		slot3.add_child(instance)
		itemslot3 = instance
		item_counter += 1
		check_stats(instance)
	elif item_counter == 3:
		var instance = item.instantiate()
		slot4.add_child(instance)
		itemslot4 = instance
		item_counter += 1
		check_stats(instance)
	elif item_counter == 4:
		var instance = item.instantiate()
		slot5.add_child(instance)
		itemslot5 = instance
		item_counter += 1
		check_stats(instance)
	elif item_counter == 5:
		var instance = item.instantiate()
		slot6.add_child(instance)
		itemslot6 = instance
		item_counter += 1
		check_stats(instance)


func check_stats(item_scene):#ottaa statsit talteen
	#print(item_scene)
	#print(item_scene.stat_and_value_returner("stat"))
	if item_scene.stat_and_value_returner("stat") == "attack damage":
		attack_damage_amount += item_scene.stat_and_value_returner("value")

func return_stats(stat):#statsit pelaajalle
	if stat == "attack damage":
		return attack_damage_amount
