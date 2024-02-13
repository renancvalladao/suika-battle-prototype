extends Control

@onready var balls_quantity = $BallsQuantity

func _process(_delta):
	balls_quantity.text = "%s" % GameManager.max_balls

func _on_minus_button_pressed():
	GameManager.max_balls -= 1
	if GameManager.max_balls <= 1:
		GameManager.max_balls = 1

func _on_plus_button_pressed():
	GameManager.max_balls += 1
