extends Node2D

var character_images = {
	GameManager.CHARACTER.QUANTITY: preload("res://assets/characters/quantity_scale.jpg"),
	GameManager.CHARACTER.FUSION: preload("res://assets/characters/fusion_scale.jpg"),
	GameManager.CHARACTER.AREA: preload("res://assets/characters/area_scale.png"),
	GameManager.CHARACTER.ALL: preload("res://assets/characters/all_scale.jpg")
}

var enemy_1_scene: PackedScene = preload("res://enemies/enemy1/enemy_1.tscn")
var enemy_damage: PackedScene = preload("res://enemies/damage/damage.tscn")
var enemy_rock: PackedScene = preload("res://enemies/rock/rock.tscn")

@export var max_moves: int = GameManager.max_balls

@onready var moves_left_label = $MovesLeftLabel
@onready var enemy: Enemy = null
@onready var enemies: Array[PackedScene]
@onready var spawn_timer = $SpawnTimer

@onready var position_min = $PositionMin
@onready var position_max = $PositionMax
@onready var game_over = $CanvasLayer/GameOver
@onready var check_button = $CheckButton
@onready var auto_check_button = $AutoCheckButton
@onready var scale_tier_button = $ScaleTierButton
@onready var pick_random_button = $PickRandomButton
@onready var fusions_label = $FusionsLabel
@onready var character = $Character
@onready var turn_counter_label = $TurnCounterLabel

@onready var spawn_point_1 = $SpawnPoint1
@onready var spawn_point_2 = $SpawnPoint2
@onready var spawn_point_3 = $SpawnPoint3
@onready var spawn_point_4 = $SpawnPoint4


var ball_scene: PackedScene = preload("res://ball/ball.tscn")
var enemy_ball_scene: PackedScene = preload("res://enemy_ball/enemy_ball.tscn")
var moves_left: int = max_moves
var turn: int = 0

func _ready():
	BallsManager.ball_exploded.connect(on_ball_exploded)
	BallsManager.ball_dropped.connect(ball_dropped)
	SignalManager.turn_started.connect(turn_started)
	SignalManager.spawn_random_ball.connect(spawn_random_ball)
	SignalManager.on_game_over.connect(on_game_over)
	SignalManager.explode_ball_tier.connect(explode_ball_tier)
	SignalManager.enemy_moved.connect(on_enemy_moved)
	SignalManager.enemy_died.connect(_on_enemy_death)
	BallsManager.turn_finished.connect(on_end_turn)
	check_button.button_pressed = BallsManager.balls_effect
	check_button.pressed.connect(toggle_ball_effect)
	auto_check_button.button_pressed = BallsManager.auto_enemy
	auto_check_button.pressed.connect(toggle_auto_enemy)
	scale_tier_button.button_pressed = BallsManager.scale_with_tier
	scale_tier_button.pressed.connect(toggle_scale_tier)
	pick_random_button.button_pressed = BallsManager.pick_random
	pick_random_button.pressed.connect(toggle_pick_random)
	moves_left_label.text = "Balls Left: %s" % moves_left
	fusions_label.text = "Fusions: 0"
	character.texture = character_images[GameManager.character_chosen]
	turn_counter_label.text = "Turn: 0"
	
	enemies = [enemy_damage]
	#spawn_enemy(spawn_point_1)
	
	#spawn_random_balls(50)
	SignalManager.turn_started.emit()
	SignalManager.balls_left_gained.connect(on_balls_left_gained)

func on_balls_left_gained(amount: int):
	moves_left += amount
	moves_left_label.text = "Balls Left: %s" % moves_left

func toggle_pick_random():
	BallsManager.pick_random = !BallsManager.pick_random
	pick_random_button.button_pressed = BallsManager.pick_random

func toggle_scale_tier():
	BallsManager.scale_with_tier = !BallsManager.scale_with_tier
	scale_tier_button.button_pressed = BallsManager.scale_with_tier

func toggle_ball_effect():
	BallsManager.balls_effect = !BallsManager.balls_effect
	check_button.button_pressed = BallsManager.balls_effect

func toggle_auto_enemy():
	BallsManager.auto_enemy = !BallsManager.auto_enemy
	auto_check_button.button_pressed = BallsManager.auto_enemy

func spawn_random_balls(amount: int) -> void:
	BallsManager.turn_finished.emit()
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

func ball_dropped():
	#moves_left -= 1
	moves_left_label.text = "Balls Left: %s" % moves_left
	if moves_left == 0:
		SignalManager.all_balls_dropped.emit()

func on_end_turn():
	#await get_tree().create_timer(BallsManager.FINISH_TURN_DELAY).timeout
	enemy.start_turn()
	if BallsManager.auto_enemy:
		enemy.move()

func on_enemy_moved():
	SignalManager.turn_started.emit()

func turn_started() -> void:
	turn += 1
	turn_counter_label.text = "Turn: %s" % turn
	moves_left = max_moves
	moves_left_label.text = "Balls Left: %s" % moves_left
	GameManager.fusions = 0
	fusions_label.text = "Fusions: %s" % GameManager.fusions

func spawn_random_ball() -> void:
	var x = randf_range(position_min.position.x, position_max.position.x)
	var y = randf_range(position_min.position.y, position_max.position.y)
	var ball_tier = BallsManager.get_random_ball().tier
	spawn_ball(Vector2(x, y), Vector2(x, y), ball_tier - 1)

func on_game_over() -> void:
	game_over.show()

func explode_ball_tier(tier: int) -> void:
	var balls = get_tree().get_nodes_in_group("ball_%s" % tier)
	for ball in balls:
		ball.queue_free()

func _on_enemy_death():
	spawn_timer.start()

func spawn_random_enemy_ball() -> void:
	var x = randf_range(position_min.position.x, position_max.position.x)
	var y = randf_range(position_min.position.y, position_max.position.y)
	var ball_tier = BallsManager.get_random_enemy_ball().tier
	spawn_ball(Vector2(x, y), Vector2(x, y), ball_tier - 1, "enemy")

func _on_spawn_timer_timeout():
	#spawn_random_enemy_ball()
	return
	if spawn_point_1.get_child_count() == 0:
		spawn_enemy(spawn_point_1)
	elif spawn_point_2.get_child_count() == 0:
		spawn_enemy(spawn_point_2)
	elif spawn_point_3.get_child_count() == 0:
		spawn_enemy(spawn_point_3)
	elif spawn_point_4.get_child_count() == 0:
		spawn_enemy(spawn_point_4)
	else:
		spawn_timer.stop()
	
func spawn_enemy(spawn_point: Marker2D):
	var chosen_enemy_scene :PackedScene = enemies.pick_random()
	var chosen_enemy: Enemy = chosen_enemy_scene.instantiate()
	#chosen_enemy.position = spawn_point.position
	spawn_point.add_child(chosen_enemy)
