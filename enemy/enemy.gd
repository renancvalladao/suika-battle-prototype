extends Node2D

class_name Enemy

var max_hp: int = 100
@export var hp: int = 100

@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel
@onready var timer = $Timer
@onready var sprite = $Control/Sprite
@onready var icon = $Control/Icon
@onready var color_damage_ui = $ColorDamage
@onready var color_damage_sprite = $ColorDamage/Sprite
@onready var color_damage_icon = $ColorDamage/Icon
@onready var actions = $Actions
@onready var attack_button = $Actions/AttackButton
@onready var heal_button = $Actions/HealButton
@onready var chaos_button = $Actions/ChaosButton
@onready var rock_button = $Actions/RockButton
@onready var bomb_button = $Actions/BombButton
@onready var color_damage_button = $Actions/ColorDamageButton
@onready var finish_button = $Actions/FinishButton
@onready var damage_label = $DamageLabel

var enemy_damage: int = 40
var should_color_damage: bool = false
var color_damage: int = 0
var my_turn: bool = false
var attacks: Array = ["damage", "rock", "damage", "bomb", "damage", "color_damage"]
var rock_config: Dictionary = {
		"tier": -2,
		"sprite": preload("res://assets/balls/grey_body_circle.png"),
		"icon": preload("res://assets/icons/d8.png"),
		"size": 3
	}
var bomb_config: Dictionary = {
		"tier": -2,
		"sprite": preload("res://assets/balls/grey_body_circle.png"),
		"icon": preload("res://assets/icons/exploding.png"),
		"size": 2,
		"type": "bomb"
	}
var attack_count = 0
var attacks_config: Dictionary = {
	"damage": {
		"sprite": preload("res://assets/balls/red_body_circle.png"),
		"icon": preload("res://assets/icons/sword.png")
	},
	"chaos": {
		"sprite": preload("res://assets/balls/purple_body_circle.png"),
		"icon": preload("res://assets/icons/book.png")
	},
	"rock": {
		"sprite": preload("res://assets/balls/grey_body_circle.png"),
		"icon": preload("res://assets/icons/d8.png")
	},
	"bomb": {
		"sprite": preload("res://assets/balls/grey_body_circle.png"),
		"icon": preload("res://assets/icons/exploding.png")
	},
	"color_damage": {
		"sprite": preload("res://assets/balls/yellow_body_circle.png"),
		"icon": preload("res://assets/icons/fire.png")
	}
}

func _ready():
	SignalManager.enemy_damaged.connect(enemy_damaged)
	BallsManager.turn_finished.connect(turn_finished)
	BallsManager.ball_exploded.connect(ball_exploded)
	attack_button.pressed.connect(on_attack_button)
	heal_button.pressed.connect(on_heal_button)
	chaos_button.pressed.connect(on_chaos_button)
	rock_button.pressed.connect(on_rock_button)
	bomb_button.pressed.connect(on_bomb_button)
	color_damage_button.pressed.connect(on_color_damage_button)
	finish_button.pressed.connect(finish_enemy_turn)
	damage_label.text = str(enemy_damage)
	set_hp(hp)

func on_attack_button():
	damage()

func on_heal_button():
	heal()

func on_chaos_button():
	chaos()

func on_rock_button():
	rock()

func on_bomb_button():
	bomb()

func on_color_damage_button():
	_color_damage()

func turn_finished() -> void:
	await get_tree().create_timer(BallsManager.FINISH_TURN_DELAY).timeout
	should_color_damage = false
	color_damage_ui.visible = false

func ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int) -> void:
	if should_color_damage && tier == color_damage:
		SignalManager.player_damaged.emit(10)

func set_hp(amount: int) -> void:
	hp = amount
	if hp <= 0:
		max_hp *= 2
		hp = max_hp
		health_bar.max_value = max_hp
		enemy_damage += 20
		damage_label.text = str(enemy_damage)
		#SignalManager.on_game_over.emit()
		#hide()
	elif hp > max_hp:
		hp = max_hp
	health_bar.value = hp
	health_label.text = str("%s/%s" % [hp, max_hp])

func enemy_damaged(damage: int) -> void:
	var new_hp = hp - damage
	set_hp(new_hp)

func _process(_delta):
	sprite.visible = BallsManager.auto_enemy
	icon.visible = BallsManager.auto_enemy
	var attack = attacks[attack_count % attacks.size()]
	var attack_config = attacks_config[attack]
	sprite.texture = attack_config.sprite
	icon.texture = attack_config.icon
	actions.visible = !BallsManager.auto_enemy && my_turn

func start_turn() -> void:
	my_turn = true

func move() -> void:
	var attack = attacks[attack_count % attacks.size()]
	match attack:
		"damage":
			damage()
		"chaos":
			heal()
			await chaos()
		"rock":
			heal()
			rock()
		"bomb":
			heal()
			bomb()
		"color_damage":
			heal()
			_color_damage()
	timer.start()
	await timer.timeout
	timer.start()
	await timer.timeout
	attack_count += 1
	finish_enemy_turn()

func finish_enemy_turn():
	my_turn = false
	SignalManager.enemy_moved.emit()

func damage():
	SignalManager.player_damaged.emit(enemy_damage)

func heal():
	set_hp(hp + 15)

func chaos():
	for i in range(10):
		SignalManager.spawn_random_ball.emit()
		timer.start()
		await timer.timeout

func rock():
	BallsManager.set_current_ball(rock_config)
	BallsManager.set_next_ball(rock_config)

func bomb():
	BallsManager.set_current_ball(bomb_config)

func _color_damage():
	should_color_damage = true
	var ball = BallsManager.BALLS.pick_random()
	color_damage_icon.texture = ball.icon
	color_damage_sprite.texture = ball.sprite
	color_damage = ball.tier
	color_damage_ui.visible = true
