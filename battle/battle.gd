extends Node2D

@export var max_moves: int = 3

@onready var moves_left_label = $MovesLeftLabel
@onready var enemy: Enemy = $Enemy
@onready var position_min = $PositionMin
@onready var position_max = $PositionMax

var ball_scene: PackedScene = preload("res://ball/ball.tscn")
var moves_left: int = 3

func _ready():
	BallsManager.ball_exploded.connect(spawn_ball)
	BallsManager.ball_dropped.connect(ball_dropped)
	SignalManager.turn_started.connect(turn_started)
	SignalManager.spawn_random_ball.connect(spawn_random_ball)

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
		await get_tree().create_timer(BallsManager.FINISH_TURN_DELAY).timeout
		await enemy.move()
		SignalManager.turn_started.emit()

func turn_started() -> void:
	moves_left = max_moves
	moves_left_label.text = "Moves Left: %s" % moves_left

func spawn_random_ball() -> void:
	var x = randf_range(position_min.position.x, position_max.position.x)
	var y = randf_range(position_min.position.y, position_max.position.y)
	var ball_tier = BallsManager.get_random_ball().tier
	spawn_ball(Vector2(x, y), Vector2(x, y), ball_tier - 1)
