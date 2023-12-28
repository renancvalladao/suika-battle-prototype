extends Control

@onready var sprite = $NextBall/Sprite
@onready var icon = $NextBall/Icon

func _ready():
	BallsManager.next_ball_changed.connect(next_ball_changed)
	set_next_ball()

func set_next_ball() -> void:
	var next_ball = BallsManager.get_next_ball()
	sprite.texture = next_ball.sprite
	icon.texture = next_ball.icon

func next_ball_changed() -> void:
	set_next_ball()
