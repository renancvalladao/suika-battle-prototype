extends Node

signal ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int, owner: String)
signal next_ball_changed
signal ball_dropped
signal turn_finished
signal current_ball_changed

var character_selection: PackedScene = load("res://character_selection/character_selection.tscn")
var battle: PackedScene = load("res://battle/battle.tscn")
var can_change_next_ball = true

const PROPORTION = [1.2, 1.3]

const RAINBOW_CONFIG: Dictionary = {
	"tier": -1,
	"sprite": preload("res://assets/balls/black_body_circle.png"),
	"size": 1,
	"owner": "player",
	"sprite_scale": 0.1875
}

const BOMB_CONFIG: Dictionary = {
	"tier": -2,
	"sprite": preload("res://assets/balls/black_body_circle.png"),
	"size": (PROPORTION[0] ** 2) * (PROPORTION[1] ** 1),
	"owner": "player",
	"type": "bomb",
	"sprite_scale": 0.1875
	}

const ENEMIES = [
	{
		"tier": 1,
		"sprite": preload("res://assets/enemies/monster_ball.png"),
		"size": PROPORTION[0] ** 0,
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/yurei.tres"),
		"preview": preload("res://assets/enemy_balls/Yurei.png")
	},
	{
		"tier": 2,
		"sprite": preload("res://assets/enemies/monster_ball_2.png"),
		"size": PROPORTION[0] ** 1,
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/chochinobake.tres"),
		"preview": preload("res://assets/enemy_balls/Chochinobake.png")
	},
	{
		"tier": 3,
		"sprite": preload("res://assets/enemies/monster_ball_3.png"),
		"size": PROPORTION[0] ** 2,
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/kappa.tres"),
		"preview": preload("res://assets/enemy_balls/Kappa.png")
	},
	{
		"tier": 4,
		"sprite": preload("res://assets/enemies/monster_ball_4.png"),
		"size": (PROPORTION[0] ** 2) * (PROPORTION[1] ** 1),
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/tanuki.tres"),
		"preview": preload("res://assets/enemy_balls/Tanuki.png")
	},
	{
		"tier": 5,
		"sprite": preload("res://assets/enemies/monster_ball_5.png"),
		"size": (PROPORTION[0] ** 3) * (PROPORTION[1] ** 1),
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/baku.tres"),
		"preview": preload("res://assets/enemy_balls/Baku.png")
	},
	{
		"tier": 6,
		"sprite": preload("res://assets/enemies/monster_ball_6.png"),
		"size": (PROPORTION[0] ** 4) * (PROPORTION[1] ** 1),
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/jogorumo.tres")
	},
	{
		"tier": 7,
		"sprite": preload("res://assets/enemies/monster_ball_7.png"),
		"size":(PROPORTION[0] ** 4) * (PROPORTION[1] ** 2),
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/oni.tres")
	},
	{
		"tier": 8,
		"sprite": preload("res://assets/enemies/monster_ball_8.png"),
		"size": (PROPORTION[0] ** 5) * (PROPORTION[1] ** 2),
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/tengu.tres")
	},
	{
		"tier": 9,
		"sprite": preload("res://assets/enemies/monster_ball_9.png"),
		"size": (PROPORTION[0] ** 6) * (PROPORTION[1] ** 2),
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/wanyudo.tres"),
		"sprite_scale": 0.9
	},
	{
		"tier": 10,
		"sprite": preload("res://assets/enemies/monster_ball_10.png"),
		"size": (PROPORTION[0] ** 6) * (PROPORTION[1] ** 3),
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/yuki_onna.tres"),
		"sprite_scale": 0.825
	},
	{
		"tier": 11,
		"sprite": preload("res://assets/enemies/monster_ball_11.png"),
		"size": (PROPORTION[0] ** 7) * (PROPORTION[1] ** 3),
		"owner": "enemy",
		"animation": preload("res://assets/enemy_balls/animations/kitsune.tres"),
		"sprite_scale": 0.8
	},
]

const BALLS = [
	{
		"tier": 1,
		"sprite": preload("res://assets/hitodama/Hitodama_1.png"),
		"size": PROPORTION[0] ** 0,
		"owner": "player"
	},
	{
		"tier": 2,
		"sprite": preload("res://assets/hitodama/Hitodama_2.png"),
		"size": PROPORTION[0] ** 1,
		"owner": "player"
	},
	{
		"tier": 3,
		"sprite": preload("res://assets/hitodama/Hitodama_3.png"),
		"size": PROPORTION[0] ** 2,
		"owner": "player"
	},
	{
		"tier": 4,
		"sprite": preload("res://assets/hitodama/Hitodama_4.png"),
		"size": (PROPORTION[0] ** 2) * (PROPORTION[1] ** 1),
		"owner": "player"
	},
	{
		"tier": 5,
		"sprite": preload("res://assets/hitodama/Hitodama_5.png"),
		"size": (PROPORTION[0] ** 3) * (PROPORTION[1] ** 1),
		"owner": "player"
	},
	{
		"tier": 6,
		"sprite": preload("res://assets/hitodama/Hitodama_6.png"),
		"size": (PROPORTION[0] ** 4) * (PROPORTION[1] ** 1),
		"owner": "player"
	},
	{
		"tier": 7,
		"sprite": preload("res://assets/hitodama/Hitodama_7.png"),
		"size": (PROPORTION[0] ** 4) * (PROPORTION[1] ** 2),
		"owner": "player"
	},
	{
		"tier": 8,
		"sprite": preload("res://assets/hitodama/Hitodama_8.png"),
		"size": (PROPORTION[0] ** 5) * (PROPORTION[1] ** 2),
		"owner": "player",
		"sprite_scale": 0.88
	},
	{
		"tier": 9,
		"sprite": preload("res://assets/hitodama/Hitodama_9.png"),
		"size": (PROPORTION[0] ** 6) * (PROPORTION[1] ** 2),
		"owner": "player",
		"sprite_scale": 0.75
	},
	{
		"tier": 10,
		"sprite": preload("res://assets/hitodama/Hitodama_10.png"),
		"size": (PROPORTION[0] ** 6) * (PROPORTION[1] ** 3),
		"owner": "player",
		"sprite_scale": 0.65
	},
	{
		"tier": 11,
		"sprite": preload("res://assets/hitodama/Hitodama_11.png"),
		"size": (PROPORTION[0] ** 7) * (PROPORTION[1] ** 3),
		"owner": "player",
		"sprite_scale": 0.6
	}
]

var rng = RandomNumberGenerator.new()
var current_ball
var next_ball
var turn = 0
var balls_effect: bool = false
var auto_enemy: bool = true
var tier: int = 1
var scale_with_tier: bool = true
var pick_random: bool = true
var is_dropping: bool = false
var count := -1

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	SignalManager.turn_started.connect(_turn_started)
	SignalManager.can_change_next_ball.connect(set_can_change_next_ball)
	SignalManager.is_dropping.connect(set_is_dropping)
	BallsManager.ball_dropped.connect(set_is_dropping_false)
	
	current_ball = get_random_enemy_ball()
	next_ball = get_random_ball()

func set_is_dropping():
	is_dropping = true
	count += 1

func set_is_dropping_false():
	is_dropping = false

func get_random_ball() -> Dictionary:
	var random_ball_index = rng.randi_range(0, 4)
	var random_ball_config = BALLS[random_ball_index]
	
	#CHANCE TO SPAWN BALL TYPES
	var i: float = randf_range(0,1)
	var type_ball_config: Dictionary
	var all_type_ball_configs: Array[Dictionary] = []
	
	if i <= GameManager.spawn_chance_ghost_ball:
		type_ball_config = random_ball_config.duplicate()
		type_ball_config["type"] = "ghost"
		all_type_ball_configs.append(type_ball_config)
		
	if i <= GameManager.spawn_chance_rainbow_ball:
		all_type_ball_configs.append(RAINBOW_CONFIG)
		
	if i <= GameManager.spawn_chance_bomb_ball:
		all_type_ball_configs.append(BOMB_CONFIG)
		
	if all_type_ball_configs.size() > 0:
		random_ball_config = all_type_ball_configs.pick_random()
	
	return random_ball_config

func get_random_enemy_ball() -> Dictionary:
	var random_ball_index = rng.randi_range(0, 4)
	return ENEMIES[random_ball_index]

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
	if (count == GameManager.balls_per_enemy - 1):
		next_ball = get_random_enemy_ball()
		count = -2
	else:
		next_ball = get_random_ball()
	next_ball_changed.emit()

func _turn_started() -> void:
	turn = 0

func _unhandled_input(event):
	if event.is_action_pressed("change_next") && can_change_next_ball && !is_dropping:
		if current_ball.has("type") && current_ball.type == "bomb":
			return
		if current_ball.has("owner") && current_ball.owner == "enemy":
			return
		if next_ball.has("owner") && next_ball.owner == "enemy":
			return
		var next = next_ball
		set_next_ball(current_ball)
		set_current_ball(next)
	if event.is_action_pressed("restart"):
		get_tree().change_scene_to_packed(battle)
		#get_tree().reload_current_scene()
		current_ball = get_random_enemy_ball()
		next_ball = get_random_ball()
		can_change_next_ball = true
		count = -1

	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
