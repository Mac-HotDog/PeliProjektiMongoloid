extends Node3D

var max_size = 15
var cc_duration = 1

var player

@onready var mesh = $MeshInstance3D3
@onready var collisionarea = $Area3D/CollisionShape3D
@onready var o_mesh_size = mesh.mesh.size
@onready var o_area_size = collisionarea.shape.radius

func _ready():
	mesh.mesh.size.x = 1
	mesh.mesh.size.y = 1
	collisionarea.shape.radius = 0.5

func get_player(x):
	player = x

func reset_area():#?
	pass
#	mesh.mesh.size = o_mesh_size
#	collisionarea.shape.radius = o_area_size

func _physics_process(delta):
 
	if mesh != null and mesh.mesh.size.x <= max_size:
		mesh.mesh.size.y += 0.2
		mesh.mesh.size.x += 0.2
	if mesh.mesh.size.x > max_size:
		mesh.visible = false
		
	if collisionarea != null and collisionarea.shape.radius <= max_size:
		collisionarea.shape.radius += 0.1
	if collisionarea != null and collisionarea.shape.radius > max_size:
		collisionarea.disabled = true

func _on_area_3d_area_entered(area):
	if area.get_parent() is Enemy:
		#print(player)
		area.get_parent().knocked_up(cc_duration)
		area.get_parent().change_health(-player.stomp_dmg_returner())
