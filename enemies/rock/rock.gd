extends Enemy
class_name Rock

const MOVE_COOLDOWN = 30

@onready var damage_numbers_origin = $DamageNumbersOrigin

var rock_config: Dictionary = {
		"tier": -2,
		"sprite": preload("res://assets/balls/grey_body_circle.png"),
		"icon": preload("res://assets/icons/d8.png"),
		"size": 3
	}

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
	rock()

func rock() -> void:
	#BallsManager.set_current_ball(rock_config)
	BallsManager.set_next_ball(rock_config)
