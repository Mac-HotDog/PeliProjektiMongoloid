extends Control
class_name Shop

@export var player_path = "/root/level1/Mannekiini"
@export var dagger_scene = preload("res://Scenes/items/dagger.tscn")
@onready var dagger = $Control/GridContainer/shopslot1/Dagger
var player #= get_node(player_path)
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
@onready var tooltip = $tooltip
var item_cost
var target_item
var target_item_name
var slot_selected

func _ready():
	tooltip.visible = false
	player = get_node(player_path)
	self.visible = false

func _on_button_pressed():
	player.shop_was_closed()
	if self.visible == true:
		self.visible = false

func send_item_cost():
	player.buy_item(item_cost)#lähettää hinnan pelaajalle

func buy_from_shop():
	player.add_item(target_item, target_item_name)#scene
	#if slot_selected == 1:
		#player.add_item("dagger")


func _on_costslot_1_pressed():
	slot_selected = 1
	item_cost = int(slot1_cost.text)#[:-1]
	#print(slot1.get_child(1))
	#target_item = slot1.get_child(1)
	target_item = dagger_scene
	target_item_name = "dagger"
	#print("h")
	send_item_cost()

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	var vektori = Vector2(mouse_pos[0] + 30,mouse_pos[1])
	tooltip.set_global_position(vektori)



func _on_area_for_tooltip_mouse_entered():
	tooltip.visible = true
	tooltip.text = "Dagger: " + str(dagger.stat_and_value_returner("value")) + " " + dagger.stat_and_value_returner("stat")


func _on_area_for_tooltip_mouse_exited():
	tooltip.visible = false
