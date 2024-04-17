class_name Enemy
extends Node

@onready var health_component: HealthComponent = $HealthComponent
@onready var shield_component: ShieldComponent = $ShieldComponent
@onready var timer = $Timer

var my_turn := false



func _ready():
	SignalManager.enemy_damaged.connect(enemy_damaged)

func start_turn() -> void:
	my_turn = true

func finish_enemy_turn():
	my_turn = false
	SignalManager.enemy_moved.emit()

func enemy_damaged(amount: int) -> void:
	var damage_taken: int = shield_component.take_shield_damage(amount)
	if damage_taken > 0:
		health_component.take_damage(damage_taken)

func move() -> void:
	pass
