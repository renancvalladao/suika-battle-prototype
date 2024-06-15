extends Node

signal ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int)
signal next_ball_changed
signal ball_dropped
signal turn_finished
signal current_ball_changed

var character_selection: PackedScene = load("res://character_selection/character_selection.tscn")
var can_change_next_ball = true

const PROPORTION = [1.2, 1.3]

const BALLS = [
	{
		"tier": 1,
		"sprite": preload("res://assets/balls/red_body_circle.png"),
		"icon": preload("res://assets/icons/tag_1.png"),
		"size": PROPORTION[0] ** 0
	},
	{
		"tier": 2,
		"sprite": preload("res://assets/balls/green_body_circle.png"),
		"icon": preload("res://assets/icons/tag_1.png"),
		"size": PROPORTION[0] ** 1
	},
	{
		"tier": 3,
		"sprite": preload("res://assets/balls/blue_body_circle.png"),
		"icon": preload("res://assets/icons/tag_1.png"),
		"size": PROPORTION[0] ** 2
	},
	{
		"tier": 4,
		"sprite": preload("res://assets/balls/red_body_circle.png"),
		"icon": preload("res://assets/icons/tag_2.png"),
		"size": (PROPORTION[0] ** 2) * (PROPORTION[1] ** 1)
	},
	{
		"tier": 5,
		"sprite": preload("res://assets/balls/green_body_circle.png"),
		"icon": preload("res://assets/icons/tag_2.png"),
		"size": (PROPORTION[0] ** 3) * (PROPORTION[1] ** 1)
	},
	{
		"tier": 6,
		"sprite": preload("res://assets/balls/blue_body_circle.png"),
		"icon": preload("res://assets/icons/tag_2.png"),
		"size": (PROPORTION[0] ** 4) * (PROPORTION[1] ** 1)
	},
	{
		"tier": 7,
		"sprite": preload("res://assets/balls/red_body_circle.png"),
		"icon": preload("res://assets/icons/tag_3.png"),
		"size": (PROPORTION[0] ** 4) * (PROPORTION[1] ** 2)
	},
	{
		"tier": 8,
		"sprite": preload("res://assets/balls/green_body_circle.png"),
		"icon": preload("res://assets/icons/tag_3.png"),
		"size": (PROPORTION[0] ** 5) * (PROPORTION[1] ** 2)
	},
	{
		"tier": 9,
		"sprite": preload("res://assets/balls/blue_body_circle.png"),
		"icon": preload("res://assets/icons/tag_3.png"),
		"size": (PROPORTION[0] ** 6) * (PROPORTION[1] ** 2)
	},
	{
		"tier": 10,
		"sprite": preload("res://assets/balls/yellow_body_circle.png"),
		"icon": preload("res://assets/icons/skull.png"),
		"size": (PROPORTION[0] ** 6) * (PROPORTION[1] ** 3)
	},
	{
		"tier": 11,
		"sprite": preload("res://assets/balls/purple_body_circle.png"),
		"icon": preload("res://assets/icons/crown.png"),
		"size": (PROPORTION[0] ** 7) * (PROPORTION[1] ** 3)
	}
]

const FINISH_TURN_DELAY: float = 2

var rng = RandomNumberGenerator.new()
var current_ball = get_random_ball()
var next_ball = get_random_ball()
var turn = 0
var balls_effect: bool = false
var auto_enemy: bool = true
var tier: int = 1
var scale_with_tier: bool = true
var pick_random: bool = true
var is_dropping: bool = false

func _ready():
	SignalManager.turn_started.connect(_turn_started)
	BallsManager.turn_finished.connect(_turn_finished)
	SignalManager.can_change_next_ball.connect(set_can_change_next_ball)
	SignalManager.is_dropping.connect(set_is_dropping)
	BallsManager.ball_dropped.connect(set_is_dropping_false)

func set_is_dropping():
	is_dropping = true

func set_is_dropping_false():
	is_dropping = false

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

func set_can_change_next_ball(can_change: bool) -> void:
	can_change_next_ball = can_change

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
	if event.is_action_pressed("change_next") && can_change_next_ball && !is_dropping:
		if current_ball.has("type") && current_ball.type == "bomb":
			return
		var next = next_ball
		set_next_ball(current_ball)
		set_current_ball(next)
	if event.is_action_pressed("restart"):
		get_tree().change_scene_to_packed(character_selection)
		#get_tree().reload_current_scene()
		current_ball = get_random_ball()
		next_ball = get_random_ball()
		can_change_next_ball = true
	#if event.is_action_pressed("change_tier"):
		#tier += 1
		#if tier > 3:
			#tier = 1
