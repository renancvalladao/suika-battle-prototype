extends Node

signal ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int)

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
		"size": 2
	},
	{
		"tier": 4,
		"sprite": preload("res://assets/balls/pink_body_circle.png"),
		"icon": preload("res://assets/icons/heart.png"),
		"size": 2.5
	},
	{
		"tier": 5,
		"sprite": preload("res://assets/balls/yellow_body_circle.png"),
		"icon": preload("res://assets/icons/bow.png"),
		"size": 3
	},
	{
		"tier": 6,
		"sprite": preload("res://assets/balls/red_body_circle.png"),
		"icon": preload("res://assets/icons/fire.png"),
		"size": 3.5
	}
]

func get_random_ball() -> Dictionary:
	return BALLS.pick_random()
