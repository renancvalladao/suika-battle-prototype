extends Control

@onready var sprite = $Sprite
@onready var icon = $Icon

func _ready():
	BallsManager.next_ball_changed.connect(next_ball_changed)

func next_ball_changed() -> void:
	var next_ball = BallsManager.get_next_ball()
	sprite.texture = next_ball.sprite
	icon.texture = next_ball.icon
