extends Enemy
class_name Damage

const MOVE_COOLDOWN = 30

@export var enemy_damage: int = 40
@onready var damage_numbers_origin = $DamageNumbersOrigin

func _ready():
	super._ready()
	move_bar.value = 0
	move_bar.max_value = MOVE_COOLDOWN
	SignalManager.enemy_move_delayed.connect(on_delay)
	damage_number_position = damage_numbers_origin.global_position

func _process(delta):
	move_bar.value += delta
	if move_bar.value >= move_bar.max_value:
		SignalManager.turn_off_color_damage.emit()
		SignalManager.can_change_next_ball.emit(true)
		move_bar.value = 0
		move()

func on_delay(amount: int):
	move_bar.value -= amount

func move() -> void:
	damage()

func damage() -> void:
	SignalManager.player_damaged.emit(enemy_damage)
