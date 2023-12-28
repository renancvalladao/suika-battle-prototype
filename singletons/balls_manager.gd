extends Node

signal ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int)
signal next_ball_changed

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
	}
]

var rng = RandomNumberGenerator.new()
var current_ball = get_random_ball()
var next_ball = get_random_ball()

func get_random_ball() -> Dictionary:
	var random_ball_index = rng.randi_range(0, BALLS.size() - 4)
	return BALLS[random_ball_index]

func get_current_ball() -> Dictionary:
	return current_ball

func get_next_ball() -> Dictionary:
	return next_ball

func choose_next_ball() -> void:
	current_ball = next_ball
	next_ball = get_random_ball()
	next_ball_changed.emit()
