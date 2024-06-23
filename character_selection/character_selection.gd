extends Control

@onready var balls_quantity = $BallsQuantity
@onready var actions_quantity = $ActionsQuantity
@onready var range_damage_button = $RangeDamageButton
@onready var auto_enemy_button = $AutoEnemyButton

func _ready():
	range_damage_button.button_pressed = GameManager.range_damage
	range_damage_button.pressed.connect(toggle_range_damage)
	auto_enemy_button.button_pressed = GameManager.auto_enemy
	auto_enemy_button.pressed.connect(toggle_auto_enemy)

func _process(_delta):
	balls_quantity.text = "%s" % GameManager.enemy_health
	actions_quantity.text = "%s" % GameManager.balls_per_enemy

func toggle_range_damage():
	GameManager.range_damage = !GameManager.range_damage

func toggle_auto_enemy():
	GameManager.auto_enemy = !GameManager.auto_enemy

func _on_minus_button_pressed():
	GameManager.enemy_health -= 1
	if GameManager.enemy_health <= 1:
		GameManager.enemy_health = 1

func _on_plus_button_pressed():
	GameManager.enemy_health += 1

func _on_action_minus_pressed():
	GameManager.balls_per_enemy -= 1
	if GameManager.balls_per_enemy <= 1:
		GameManager.balls_per_enemy = 1

func _on_action_plus_pressed():
	GameManager.balls_per_enemy += 1
