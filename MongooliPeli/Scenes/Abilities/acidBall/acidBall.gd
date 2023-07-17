extends Node3D

var ball = preload("res://Scenes/Abilities/acidBall/acidBallProjectile.tscn")


func execute(node):
	var ball2 = ball.instantiate()
	ball2.linear_velocity = Vector3(10, 1, 0)
	
	add_child(ball2)
