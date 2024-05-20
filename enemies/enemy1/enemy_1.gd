extends Enemy
class_name Enemy1

#var moves: Array[String] = ["damage", "heal", "shield", "block_ball_change", "color_damage"]
#var moves: Array[String] = ["color_damage", "shield"]

@export var enemy_damage:int = 40
@export var enemy_heal_amount:int = 15
@export var enemy_shield_amount:int = 10
@export var block_ball_change_duration: int = 2#


@onready var color_damage_component: ColorDamageComponent = $ColorDamageComponent
@export var color_damage_duration: int = 1
@export var color_damage_amount: int = 10

func _ready():
	super._ready()
	moves = ["damage", "heal", "shield", "block_ball_change", "color_damage"]
	intended_move.text = moves[0]
	if moves[move_count] == "damage":
		intended_move.text += "_" + str(enemy_damage)


func move() -> void:
	var action = moves[move_count]
	
	match action:
		"damage":
			damage()
		"heal":
			heal()
		"shield":
			shield()
		"block_ball_change":
			block_ball_change(block_ball_change_duration)
		"color_damage":
			color_damage()

	timer.start()
	await timer.timeout
	
	move_count += 1
	if move_count == moves.size():
		move_count = 0
		
	intended_move.text = moves[move_count]
	if moves[move_count] == "damage":
		intended_move.text += "_" + str(enemy_damage)
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

func block_ball_change(duration: int) -> void:
	var debuff: Debuff = BlockBallChange.new()
	debuff.duration = block_ball_change_duration
	debuff.start_debuff()
	debuffs.append(debuff)

func color_damage():
	color_damage_component.set_damage_amount(color_damage_amount)
	var debuff: Debuff = ColorDamageDebuff.new()
	debuff.duration = color_damage_duration
	debuff.start_debuff()
	debuffs.append(debuff)
