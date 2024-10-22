extends Node

@export
var explosion_scene: PackedScene = preload("res://explosion/explosion.tscn")

func _ready():
	SignalManager.create_explosion.connect(create_explosion)

func create_explosion(enemy_position: Vector2):
	var explosion = explosion_scene.instantiate()
	explosion.position = enemy_position
	explosion.emitting = true
	get_tree().current_scene.add_child(explosion)
	await explosion.finished
	explosion.queue_free()	
