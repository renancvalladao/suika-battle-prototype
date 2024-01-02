extends Node2D

@export var hp: int = 100

@onready var progress_bar = $ProgressBar

func _ready():
	BallsManager.ball_exploded.connect(ball_exploded)
	progress_bar.value = hp

func ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int) -> void:
	hp -= 10
	if hp < 0:
		hp = 0
	progress_bar.value = hp
