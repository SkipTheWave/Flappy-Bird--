extends Area2D

@export var score := 5

signal pickup

func _on_body_entered(body):
	pickup.emit(self)
