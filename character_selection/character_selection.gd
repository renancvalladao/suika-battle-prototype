extends Control

@onready var balls_quantity = $BallsQuantity
@onready var actions_quantity = $ActionsQuantity

func _process(_delta):
	balls_quantity.text = "%s" % GameManager.max_balls
	actions_quantity.text = "%s" % GameManager.max_actions

func _on_minus_button_pressed():
	GameManager.max_balls -= 1
	if GameManager.max_balls <= 1:
		GameManager.max_balls = 1

func _on_plus_button_pressed():
	GameManager.max_balls += 1

func _on_action_minus_pressed():
	GameManager.max_actions -= 1
	if GameManager.max_actions <= 1:
		GameManager.max_actions = 1

func _on_action_plus_pressed():
	GameManager.max_actions += 1
