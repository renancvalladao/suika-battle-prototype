extends Node2D

var ball_scene: PackedScene = preload("res://ball/ball.tscn")

func _ready():
	BallsManager.ball_exploded.connect(spawn_ball)

func spawn_ball(first_pos: Vector2, second_pos: Vector2, tier: int):
	if tier == BallsManager.BALLS.size():
		return
	var ball_position = (first_pos + second_pos) / 2
	var ball_config = BallsManager.BALLS[tier]
	var ball = ball_scene.instantiate()
	ball.position = ball_position
	ball.set_configuration(ball_config)
	call_deferred("add_child", ball)
