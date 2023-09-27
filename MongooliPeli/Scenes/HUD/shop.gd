extends Control
class_name Shop

@export var player_path = "/root/level1/Mannekiini"
@export var dagger = preload("res://Scenes/items/dagger.tscn")
var player
@onready var slot1 = $Control/GridContainer/shopslot1
@onready var slot1_cost = $Control/GridContainer/shopslot1/costslot1
@onready var slot2 = $Control/GridContainer/Control/shopslot2
@onready var slot2_cost = $Control/GridContainer/shopslot2/cost
@onready var slot3 = $Control/GridContainer/Control/shopslot3
@onready var slot3_cost = $Control/GridContainer/shopslot3/cost
@onready var slot4 = $Control/GridContainer/Control/shopslot4
@onready var slot4_cost = $Control/GridContainer/shopslot4/cost
@onready var slot5 = $Control/GridContainer/Control/shopslot5
@onready var slot5_cost = $Control/GridContainer/shopslot5/cost
@onready var slot6 = $Control/GridContainer/Control/shopslot6
@onready var slot6_cost = $Control/GridContainer/shopslot6/cost
var item_cost
var target_item
var slot_selected

func _ready():
	player = get_node(player_path)
	self.visible = false

func _on_button_pressed():
	player.shop_was_closed()
	if self.visible == true:
		self.visible = false

func send_item_cost():
	player.buy_item(item_cost)#onks massii

func buy_from_shop():
	player.add_item(target_item)#scene
	if slot_selected == 1:
		player.add_item("dagger")


func _on_costslot_1_pressed():
	slot_selected = 1
	item_cost = int(slot1_cost.text)#[:-1]
	#print(slot1.get_child(1))
	#target_item = slot1.get_child(1)
	target_item = dagger
	#print("h")
	send_item_cost()

