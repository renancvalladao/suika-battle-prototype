extends Node2D

class_name Enemy

@export var hp: int = 100

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var my_turn: bool = false
var attacks: Array = ["damage", "chaos", "rock"]
var rock_config: Dictionary = {
		"tier": BallsManager.BALLS.size(),
		"sprite": preload("res://assets/balls/grey_body_circle.png"),
		"icon": preload("res://assets/icons/d8.png"),
		"size": 3
	}
var attack_count = 0

func _ready():
	BallsManager.ball_exploded.connect(ball_exploded)
	progress_bar.value = hp

func ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int) -> void:
	if my_turn:
		return
	hp -= 10
	if hp < 0:
		queue_free()
	progress_bar.value = hp

func move() -> void:
	my_turn = true
	var attack = attacks[attack_count % attacks.size()]
	attack_count += 1
	match attack:
		"damage":
			SignalManager.player_damaged.emit(40)
		"chaos":
			for i in range(10):
				SignalManager.spawn_random_ball.emit()
				timer.start()
				await timer.timeout
		"rock":
			BallsManager.set_current_ball(rock_config)
			BallsManager.set_next_ball(rock_config)
	timer.start()
	await timer.timeout
	my_turn = false
