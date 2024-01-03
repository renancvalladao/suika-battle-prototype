extends Node2D

class_name Enemy

@export var hp: int = 100

@onready var progress_bar = $ProgressBar

func _ready():
	BallsManager.ball_exploded.connect(ball_exploded)
	progress_bar.value = hp

func ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int) -> void:
	hp -= 10
	if hp < 0:
		queue_free()
	progress_bar.value = hp

func move() -> void:
	SignalManager.player_damaged.emit(20)
	SignalManager.turn_started.emit()
