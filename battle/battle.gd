extends Node2D

@onready var position_min = $PositionMin
@onready var position_max = $PositionMax
@onready var game_over = $CanvasLayer/GameOver
@onready var fusions_label = $FusionsLabel
@onready var game_over_area = $GameOverArea

var ball_scene: PackedScene = preload("res://ball/ball.tscn")
var enemy_ball_scene: PackedScene = preload("res://enemy_ball/enemy_ball.tscn")

func _ready():
	BallsManager.ball_exploded.connect(on_ball_exploded)
	SignalManager.spawn_random_ball.connect(spawn_random_ball)
	SignalManager.on_game_over.connect(on_game_over)
	fusions_label.text = "Fusions: 0"
	
	#spawn_random_balls(50)
	SignalManager.turn_started.emit()
	#spawn_multiple_random_enemy_ball()

func _process(_delta):
	if game_over_area.get_overlapping_bodies().size() > 0:
		for body in game_over_area.get_overlapping_bodies():
			if body.is_in_group("balls"):
				SignalManager.on_game_over.emit()

func spawn_random_balls(amount: int) -> void:
	for i in range(amount):
		SignalManager.spawn_random_ball.emit()
		await get_tree().create_timer(.5).timeout
	await get_tree().create_timer(2).timeout

func on_ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int, owner: String) -> void:
	GameManager.fusions += 1
	fusions_label.text = "Fusions: %s" % GameManager.fusions
	spawn_ball(first_pos, second_pos, tier, owner)

func spawn_ball(first_pos: Vector2, second_pos: Vector2, tier: int, owner: String = "player"):
	if owner == "player" && tier == BallsManager.BALLS.size():
		return
	if owner == "enemy" && tier == BallsManager.ENEMIES.size():
		return
	var ball_position = (first_pos + second_pos) / 2
	var ball_config
	var ball
	if owner == "player":
		ball_config = BallsManager.BALLS[tier]
		ball = ball_scene.instantiate()
	else:
		ball_config = BallsManager.ENEMIES[tier]
		ball = enemy_ball_scene.instantiate()
	ball.position = ball_position
	ball.set_configuration(ball_config)
	call_deferred("add_child", ball)

func spawn_random_ball() -> void:
	var x = randf_range(position_min.position.x, position_max.position.x)
	var y = randf_range(position_min.position.y, position_max.position.y)
	var ball_tier = BallsManager.get_random_ball().tier
	spawn_ball(Vector2(x, y), Vector2(x, y), ball_tier - 1)

func on_game_over() -> void:
	game_over.show()

func spawn_random_enemy_ball() -> void:
	var x = randf_range(position_min.position.x, position_max.position.x)
	var y = randf_range(position_min.position.y, position_max.position.y)
	var ball_tier = BallsManager.get_random_enemy_ball().tier
	spawn_ball(Vector2(x, y), Vector2(x, y), ball_tier - 1, "enemy")

func spawn_multiple_random_enemy_ball() -> void:
	for i in range(5):
		spawn_random_enemy_ball()
		await get_tree().create_timer(3.0).timeout
