extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var audio_fire: AudioStreamPlayer2D = $audio_fire
var is_valid = true

func _ready():
	pass


func explode():
	is_valid = false
	sprite.play("explode")
	await sprite.animation_finished
	queue_free()
