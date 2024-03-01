extends Area2D

@export var score := 2
@export var speed_inc := 6

signal pickup

func _on_body_entered(body):
	pickup.emit(self)
