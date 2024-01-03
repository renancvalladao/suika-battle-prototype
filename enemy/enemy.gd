extends Node2D

class_name Enemy

@export var hp: int = 100

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var my_turn = false

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
	SignalManager.player_damaged.emit(20)
	for i in range(10):
		SignalManager.spawn_random_ball.emit()
		timer.start()
		await timer.timeout
	await timer.timeout
	my_turn = false
