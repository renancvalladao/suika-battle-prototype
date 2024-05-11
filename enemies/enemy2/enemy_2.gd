extends Enemy
class_name Enemy2

#var moves: Array[String] = ["damage", "heal", "shield", "block_ball_change", "color_damage"]
#var moves: Array[String] = ["color_damage", "shield"]
@onready var change_color_component: ChangeColorComponent = $ChangeColorComponent

@export var enemy_damage:int = 40
@export var enemy_heal_amount:int = 15
@export var enemy_shield_amount:int = 10
@export var block_ball_change_duration: int = 2#

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

func _ready():
	super._ready()
	moves = ["change_color", "rock", "damage", "bomb", "heal", "shield"]
	intended_move.text = moves[0]
	if intended_move.text == "change_color":
		change_color_component.choose_random_colors()
		change_color_component.visible = true
		intended_move.visible = false
	else:
		change_color_component.visible = false

func move() -> void:
	var action = moves[move_count]
	
	match action:
		"damage":
			damage()
		"heal":
			heal()
		"shield":
			shield()
		"rock":
			rock()
		"bomb":
			bomb()
		"change_color":
			change_color()


	timer.start()
	await timer.timeout
	
	move_count += 1
	if move_count == moves.size():
		move_count = 0
		
	intended_move.text = moves[move_count]
	
	if intended_move.text == "change_color":
		change_color_component.choose_random_colors()
		intended_move.visible = false
		change_color_component.visible = true
	else:
		intended_move.visible = true
		change_color_component.visible = false
		
	finish_enemy_turn()

func finish_enemy_turn() -> void:
	my_turn = false
	SignalManager.enemy_moved.emit()

func damage() -> void:
	SignalManager.player_damaged.emit(enemy_damage)
	print("damage")

func heal() -> void:
	health_component.heal(enemy_heal_amount)
	print("heal")
	
func shield() -> void:
	shield_component.gain_shield(enemy_shield_amount)
	print("shield")

func rock() -> void:
	BallsManager.set_current_ball(rock_config)
	BallsManager.set_next_ball(rock_config)
	
func bomb() -> void:
	BallsManager.set_current_ball(bomb_config)

func change_color() -> void:
	change_color_component.change_color()
