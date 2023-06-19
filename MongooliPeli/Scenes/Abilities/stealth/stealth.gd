extends Node

func execute(node):
	node.visible = false
	await get_tree().create_timer(1).timeout
	node.visible = true
