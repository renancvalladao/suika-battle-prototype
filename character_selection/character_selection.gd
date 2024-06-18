extends Control

@onready var balls_quantity = $BallsQuantity
@onready var actions_quantity = $ActionsQuantity

func _process(_delta):
	balls_quantity.text = "%s" % GameManager.max_balls
	actions_quantity.text = "%s" % GameManager.balls_per_enemy

func _on_minus_button_pressed():
	GameManager.max_balls -= 1
	if GameManager.max_balls <= 1:
		GameManager.max_balls = 1

func _on_plus_button_pressed():
	GameManager.max_balls += 1

func _on_action_minus_pressed():
	GameManager.balls_per_enemy -= 1
	if GameManager.balls_per_enemy <= 1:
		GameManager.balls_per_enemy = 1

func _on_action_plus_pressed():
	GameManager.balls_per_enemy += 1
