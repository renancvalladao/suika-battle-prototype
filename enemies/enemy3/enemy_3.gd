extends Enemy
class_name Enemy3

#var moves: Array[String] = ["damage", "heal", "shield", "block_ball_change", "color_damage"]
#var moves: Array[String] = ["color_damage", "shield"]
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
	moves = ["to_tier10"]
	intended_move.text = moves[0]


func move() -> void:
	var action = moves[move_count]
	
	match action:
		"to_tier10":
			to_tier10()


	timer.start()
	await timer.timeout
	
	move_count += 1
	if move_count == moves.size():
		move_count = 0
		
	intended_move.text = moves[move_count]
		
	finish_enemy_turn()

func finish_enemy_turn() -> void:
	my_turn = false
	SignalManager.enemy_moved.emit()

func to_tier10() -> void:
	var chosen_ball:Ball
	while true:
		var balls = get_tree().get_nodes_in_group("balls")
		#print(balls)
		chosen_ball = balls.pick_random()
		if chosen_ball.config.tier < 10:
			break
	chosen_ball.change_tier(10)


func damage() -> void:
	SignalManager.player_damaged.emit(enemy_damage)
	print("damage")

func heal() -> void:
	health_component.heal(enemy_heal_amount)
	print("heal")
	
func shield() -> void:
	shield_component.gain_shield(enemy_shield_amount)
	print("shield")

