extends Node

signal ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int)
signal next_ball_changed
signal ball_dropped
signal turn_finished
signal current_ball_changed

const BALLS = [
	{
		"tier": 1,
		"sprite": preload("res://assets/balls/blue_body_circle.png"),
		"icon": preload("res://assets/icons/sword.png"),
		"size": 1
	},
	{
		"tier": 2,
		"sprite": preload("res://assets/balls/purple_body_circle.png"),
		"icon": preload("res://assets/icons/shield.png"),
		"size": 1.5
	},
	{
		"tier": 3,
		"sprite": preload("res://assets/balls/green_body_circle.png"),
		"icon": preload("res://assets/icons/flask.png"),
		"size": 2.1
	},
	{
		"tier": 4,
		"sprite": preload("res://assets/balls/pink_body_circle.png"),
		"icon": preload("res://assets/icons/heart.png"),
		"size": 2.8
	},
	{
		"tier": 5,
		"sprite": preload("res://assets/balls/yellow_body_circle.png"),
		"icon": preload("res://assets/icons/bow.png"),
		"size": 3.6
	},
	{
		"tier": 6,
		"sprite": preload("res://assets/balls/red_body_circle.png"),
		"icon": preload("res://assets/icons/fire.png"),
		"size": 4.5
	},
	{
		"tier": 7,
		"sprite": preload("res://assets/balls/blue_body_circle.png"),
		"icon": preload("res://assets/icons/book.png"),
		"size": 5.5
	},
	{
		"tier": 8,
		"sprite": preload("res://assets/balls/purple_body_circle.png"),
		"icon": preload("res://assets/icons/skull.png"),
		"size": 6.6
	},
	{
		"tier": 9,
		"sprite": preload("res://assets/balls/green_body_circle.png"),
		"icon": preload("res://assets/icons/dollar.png"),
		"size": 7.8
	},
	{
		"tier": 10,
		"sprite": preload("res://assets/balls/pink_body_circle.png"),
		"icon": preload("res://assets/icons/flag_square.png"),
		"size": 9.1
	},
	{
		"tier": 10,
		"sprite": preload("res://assets/balls/yellow_body_circle.png"),
		"icon": preload("res://assets/icons/award.png"),
		"size": 10.5
	}
]

const FINISH_TURN_DELAY: float = 2

var rng = RandomNumberGenerator.new()
var current_ball = get_random_ball()
var next_ball = get_random_ball()
var turn = 0
var balls_effect: bool = true
var auto_enemy: bool = true

func _ready():
	SignalManager.turn_started.connect(_turn_started)
	BallsManager.turn_finished.connect(_turn_finished)

func get_random_ball() -> Dictionary:
	var random_ball_index = rng.randi_range(0, 4)
	return BALLS[random_ball_index]

func get_current_ball() -> Dictionary:
	return current_ball

func get_next_ball() -> Dictionary:
	return next_ball

func set_current_ball(ball: Dictionary) -> void:
	current_ball = ball
	current_ball_changed.emit()

func set_next_ball(ball: Dictionary) -> void:
	next_ball = ball
	next_ball_changed.emit()

func choose_next_ball() -> void:
	current_ball = next_ball
	next_ball = get_random_ball()
	next_ball_changed.emit()

func _turn_started() -> void:
	turn = 0

func _turn_finished() -> void:
	await get_tree().create_timer(FINISH_TURN_DELAY).timeout
	turn = 1

func _unhandled_input(event):
	if event.is_action_pressed("change_next"):
		if current_ball.has("type") && current_ball.type == "bomb":
			return
		var next = next_ball
		set_next_ball(current_ball)
		set_current_ball(next)
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
		current_ball = get_random_ball()
		next_ball = get_random_ball()
