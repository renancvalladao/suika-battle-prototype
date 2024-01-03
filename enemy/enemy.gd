extends Node2D

class_name Enemy

@export var hp: int = 100

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var my_turn: bool = false
var attacks: Array = ["damage", "chaos", "damage", "rock"]
var rock_config: Dictionary = {
		"tier": BallsManager.BALLS.size(),
		"sprite": preload("res://assets/balls/grey_body_circle.png"),
		"icon": preload("res://assets/icons/d8.png"),
		"size": 3
	}
var attack_count = 0

func _ready():
	SignalManager.enemy_damaged.connect(enemy_damaged)
	progress_bar.value = hp

func set_hp(amount: int) -> void:
	hp = amount
	progress_bar.value = amount

func enemy_damaged(damage: int) -> void:
	var new_hp = hp - damage
	if new_hp <= 0:
		new_hp = 0
		queue_free()
	set_hp(new_hp)
	

func move() -> void:
	my_turn = true
	var attack = attacks[attack_count % attacks.size()]
	attack_count += 1
	match attack:
		"damage":
			SignalManager.player_damaged.emit(40)
		"chaos":
			set_hp(hp + 20)
			for i in range(10):
				SignalManager.spawn_random_ball.emit()
				timer.start()
				await timer.timeout
		"rock":
			set_hp(hp + 20)
			BallsManager.set_current_ball(rock_config)
			BallsManager.set_next_ball(rock_config)
	timer.start()
	await timer.timeout
	my_turn = false
