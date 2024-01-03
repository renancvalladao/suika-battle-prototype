extends Node2D

@export var max_moves: int = 3

@onready var moves_left_label = $MovesLeftLabel
@onready var enemy: Enemy = $Enemy

var ball_scene: PackedScene = preload("res://ball/ball.tscn")
var moves_left: int = 3

func _ready():
	BallsManager.ball_exploded.connect(spawn_ball)
	BallsManager.ball_dropped.connect(ball_dropped)
	SignalManager.turn_started.connect(turn_started)

func spawn_ball(first_pos: Vector2, second_pos: Vector2, tier: int):
	if tier == BallsManager.BALLS.size():
		return
	var ball_position = (first_pos + second_pos) / 2
	var ball_config = BallsManager.BALLS[tier]
	var ball = ball_scene.instantiate()
	ball.position = ball_position
	ball.set_configuration(ball_config)
	call_deferred("add_child", ball)

func ball_dropped():
	moves_left -= 1
	moves_left_label.text = "Moves Left: %s" % moves_left
	if moves_left == 0:
		BallsManager.turn_finished.emit()
		await enemy.move()

func turn_started() -> void:
	moves_left = max_moves
	moves_left_label.text = "Moves Left: %s" % moves_left
