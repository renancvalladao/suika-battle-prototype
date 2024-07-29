extends Node

@export
var explosion_scene: PackedScene = preload("res://explosion/explosion.tscn")
var evolution_sprite = preload("res://assets/upgrade.svg")

func _ready():
	SignalManager.create_explosion.connect(create_explosion)

func create_explosion(enemy_position: Vector2):
	var explosion = explosion_scene.instantiate()
	explosion.position = enemy_position
	explosion.emitting = true
	get_tree().current_scene.add_child(explosion)
	await explosion.finished
	explosion.queue_free()

func display_evolution(position: Vector2, size: float):
	return
	var evolution = Sprite2D.new()
	evolution.global_position = position
	evolution.texture = evolution_sprite
	evolution.scale = Vector2(0.075, 0.075)
	evolution.scale = evolution.scale * size
	evolution.z_index = 6
	evolution.modulate.r = 1
	evolution.modulate.g = 0
	evolution.modulate.b = 0
	
	call_deferred("add_child", evolution)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(evolution, "position:y", evolution.position.y - (24 * size), 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(evolution, "position:y", evolution.position.y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.3)
	tween.tween_property(evolution, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.6)
	
	await tween.finished
	evolution.queue_free()
