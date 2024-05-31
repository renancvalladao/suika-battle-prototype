extends Control

@onready var next_ball = $NextBall
@onready var sprite = $NextBall/Sprite
@onready var icon = $NextBall/Icon
@onready var add_mana_button = $AddManaButton
@onready var balls_options = $BallsOptions
@onready var add_health_button = $AddHealthButton
@onready var red_label = $BallsCounter/RedBalls/Label
@onready var green_label = $BallsCounter/GreenBalls/Label
@onready var blue_label = $BallsCounter/BlueBalls/Label

func _ready():
	BallsManager.next_ball_changed.connect(next_ball_changed)
	SignalManager.can_change_next_ball.connect(can_change_next_ball_ui)
	add_mana_button.pressed.connect(on_add_mana)
	add_health_button.pressed.connect(on_add_health)
	var balls: Array = balls_options.get_children()
	for index in balls.size():
		var ball = balls[index]
		ball.get_child(0).texture = BallsManager.BALLS[index].sprite
		ball.get_child(1).texture = BallsManager.BALLS[index].icon
	set_next_ball()

#func _process(_delta):
	#red_label.text = "%s" % get_balls_by_color("red")
	#green_label.text = "%s" % get_balls_by_color("green")
	#blue_label.text = "%s" % get_balls_by_color("blue")
	
func can_change_next_ball_ui(can_change: bool) -> void:
	if !can_change:
		next_ball.modulate.a = 0.5
	else:
		next_ball.modulate.a = 1.0

func get_balls_by_color(color: String) -> int:
	var tiers = []
	if color == "red":
		tiers = [1, 4, 7]
	elif color == "green":
		tiers = [2, 5, 8]
	else:
		tiers = [3, 6, 9]
	var total = 0
	for tier in tiers:
		total += get_tree().get_nodes_in_group("ball_%s" % tier).size()
	return total

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
