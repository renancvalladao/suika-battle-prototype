extends Control

@onready var sprite = $NextBall/Sprite
@onready var icon = $NextBall/Icon
@onready var add_mana_button = $AddManaButton
@onready var balls_options = $BallsOptions
@onready var add_health_button = $AddHealthButton

func _ready():
	BallsManager.next_ball_changed.connect(next_ball_changed)
	add_mana_button.pressed.connect(on_add_mana)
	add_health_button.pressed.connect(on_add_health)
	var balls: Array = balls_options.get_children()
	for index in balls.size():
		var ball = balls[index]
		ball.get_child(0).texture = BallsManager.BALLS[index].sprite
		ball.get_child(1).texture = BallsManager.BALLS[index].icon
	set_next_ball()

func set_next_ball() -> void:
	var next_ball = BallsManager.get_next_ball()
	sprite.texture = next_ball.sprite
	icon.texture = next_ball.icon

func next_ball_changed() -> void:
	set_next_ball()

func on_add_mana():
	SignalManager.mana_gained.emit(100)

func on_add_health():
	SignalManager.health_gained.emit(100)
