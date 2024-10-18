extends Enemy
class_name Enemy1

#var moves: Array[String] = ["damage", "heal", "shield", "block_ball_change", "color_damage"]
#var moves: Array[String] = ["color_damage", "shield"]

const MOVE_COOLDOWN = 30

@export var enemy_damage:int = 40
@export var enemy_heal_amount:int = 15
@export var enemy_shield_amount:int = 10
@export var block_ball_change_duration: int = 2#


@onready var color_damage_component: ColorDamageComponent = $ColorDamageComponent
@export var color_damage_duration: int = 1
@export var color_damage_amount: int = 10
@onready var damage_numbers_origin = $DamageNumbersOrigin

func _ready():
	super._ready()
	#moves = ["damage", "shield", "damage", "color_damage", "damage", "block_ball_change", "damage", "heal"]
	moves = ["shield", "damage", "color_damage", "heal", "damage"]
	build_intention_string()
	move_bar.value = 0
	move_bar.max_value = MOVE_COOLDOWN
	SignalManager.enemy_move_delayed.connect(on_delay)
	damage_number_position = damage_numbers_origin.global_position
	#move_timer.start()

func _process(delta):
	move_bar.value += delta
	if move_bar.value >= move_bar.max_value:
		SignalManager.turn_off_color_damage.emit()
		SignalManager.can_change_next_ball.emit(true)
		move_bar.value = 0
		move()


func on_delay(amount: int):
	move_bar.value -= amount

func build_intention_string():
	intended_move.text = moves[move_count]
	if moves[move_count] == "color_damage":
		intended_move.text += "_" + str(color_damage_amount) + "\nblock_ball_change"
	if moves[move_count] == "damage":
		intended_move.text += "_" + str(enemy_damage)

#func display_damage_number(damage_taken: int) -> void:
#	DamageNumbers.display_number(damage_taken, damage_numbers_origin.global_position)

func move() -> void:
	var action = moves[move_count]
	
	match action:
		"damage":
			damage()
		"heal":
			heal()
		"shield":
			shield()
		#"block_ball_change":
			#block_ball_change(block_ball_change_duration)
		"color_damage":
			color_damage()
			block_ball_change(block_ball_change_duration)

	#timer.start()
	#await timer.timeout
	
	move_count += 1
	if move_count == moves.size():
		move_count = 0
		
	build_intention_string()
	#finish_enemy_turn()

func finish_enemy_turn() -> void:
	my_turn = false
	SignalManager.enemy_moved.emit()

func damage() -> void:
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

