extends AudioStreamPlayer

@export var sfx_click : AudioStream
@export var sfx_hit : AudioStream
@export var sfx_flap : AudioStream
@export var sfx_coin : AudioStream
@export var sfx_powerup : AudioStream


func _on_main_sfx_click():
	stream = sfx_click
	play()

func _on_main_sfx_coin():
	stream = sfx_coin
	play()


func _on_main_sfx_hit():
	stream = sfx_hit
	play()


func _on_main_sfx_powerup():
	stream = sfx_powerup
	play()
