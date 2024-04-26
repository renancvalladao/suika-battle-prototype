extends Enemy
class_name Enemy1

var moves: Array[String] = ["damage", "heal", "shield", "block_ball_change"]
#var moves: Array[String] = ["block_ball_change", "shield", "shield"]
var move_count := 0

@export var enemy_damage:int = 40
@export var enemy_heal_amount:int = 15
@export var enemy_shield_amount:int = 10
@export var block_ball_change_duration: int = 2

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

	timer.start()
	await timer.timeout
	
	move_count += 1
	if move_count == moves.size():
		move_count = 0
		
	finish_enemy_turn()

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
	debuffs.append(debuff)
	SignalManager.can_change_next_ball.emit(false)
	print("block ball change")
