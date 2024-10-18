extends Enemy
class_name Enemy3

#var moves: Array[String] = ["damage", "heal", "shield", "block_ball_change", "color_damage"]
#var moves: Array[String] = ["color_damage", "shield"]
@export var enemy_damage:int = 40
@export var enemy_heal_amount:int = 15
@export var enemy_shield_amount:int = 10
@export var block_ball_change_duration: int = 2#

@onready var attack_icon = preload("res://assets/icons/sword.png")
@onready var heal_icon = preload("res://assets/icons/heart.png")
@onready var shield_icon = preload("res://assets/icons/shield.png")
@onready var ball_can_attack_component: PackedScene = preload("res://components/ball_can_attack_component.tscn")
var icons: Array

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
	moves = ["to_tier10", "ball_can_attack", "ball_can_attack", "ball_can_attack", "ball_can_attack", "ball_can_attack"]
	intended_move.text = moves[0]
	icons = [attack_icon, heal_icon, shield_icon]


func move() -> void:
	var action = moves[move_count]
	
	match action:
		"to_tier10":
			to_tier10()
		"ball_can_attack":
			ball_can_attack()


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
	var balls = get_tree().get_nodes_in_group("balls")
	while true:
		#print(balls)
		chosen_ball = balls.pick_random()
		if chosen_ball.config.tier < 10:
			break
	chosen_ball.change_tier(10)

func ball_can_attack():
	var chosen_ball: Ball
	var balls = get_tree().get_nodes_in_group("balls")
	while true:
		chosen_ball = balls.pick_random()
		if !chosen_ball.is_in_group("has_ball_can_attack_component"):
			chosen_ball.add_to_group("has_ball_can_attack_component")
			break
	#var component: BallCanAttackComponent = ball_can_attack_component.instantiate()
	var component: BallCanAttackComponent = chosen_ball.ball_can_attack_component
	var attacks = [0,1,2] # 0 == Damage, 1 == Heal, 2 == Shield
	var choosen_attack = attacks.pick_random()
	
	match choosen_attack:
		0:
			component.is_damage = true
			component.texture = attack_icon
		1:
			component.is_heal = true
			component.texture = heal_icon
		2:
			component.is_shield = true
			component.texture = shield_icon

	component.scale *= chosen_ball.config.size 
	component.enemy_owner = self
	component.visible = true
	#chosen_ball.add_child(component)

func damage() -> void:
	print("damage")

func heal() -> void:
	health_component.heal(enemy_heal_amount)
	print("heal")
	
func shield() -> void:
	shield_component.gain_shield(enemy_shield_amount)
	print("shield")

