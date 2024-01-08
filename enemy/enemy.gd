extends Node2D

class_name Enemy

@export var hp: int = 100

@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel
@onready var timer = $Timer
@onready var sprite = $Control/Sprite
@onready var icon = $Control/Icon

var my_turn: bool = false
var attacks: Array = ["damage", "chaos", "damage", "rock", "damage", "bomb"]
var rock_config: Dictionary = {
		"tier": BallsManager.BALLS.size(),
		"sprite": preload("res://assets/balls/grey_body_circle.png"),
		"icon": preload("res://assets/icons/d8.png"),
		"size": 3
	}
var bomb_config: Dictionary = {
		"tier": BallsManager.BALLS.size(),
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
	}
}

func _ready():
	SignalManager.enemy_damaged.connect(enemy_damaged)
	set_hp(hp)

func set_hp(amount: int) -> void:
	hp = amount
	if hp <= 0:
		hp = 0
		SignalManager.on_game_over.emit()
		hide()
	elif hp > 100:
		hp = 100
	health_bar.value = hp
	health_label.text = str("%s/100" % hp)

func enemy_damaged(damage: int) -> void:
	var new_hp = hp - damage
	set_hp(new_hp)

func _process(_delta):
	var attack = attacks[attack_count % attacks.size()]
	var attack_config = attacks_config[attack]
	sprite.texture = attack_config.sprite
	icon.texture = attack_config.icon

func move() -> void:
	my_turn = true
	var attack = attacks[attack_count % attacks.size()]
	match attack:
		"damage":
			SignalManager.player_damaged.emit(40)
		"chaos":
			set_hp(hp + 15)
			for i in range(10):
				SignalManager.spawn_random_ball.emit()
				timer.start()
				await timer.timeout
		"rock":
			set_hp(hp + 15)
			BallsManager.set_current_ball(rock_config)
			BallsManager.set_next_ball(rock_config)
		"bomb":
			BallsManager.set_current_ball(bomb_config)
	timer.start()
	await timer.timeout
	my_turn = false
	attack_count += 1
