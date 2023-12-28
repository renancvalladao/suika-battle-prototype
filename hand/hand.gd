extends Node2D

const DROP_COOLDOWN: float = 0.4

@export var position_min: Marker2D = Marker2D.new()
@export var position_max: Marker2D = Marker2D.new()

var ball_scene: PackedScene = preload("res://ball/ball.tscn")
var position_offset: float = 0.0
var drop_timer: float = 1.0

func _ready():
	position_offset = $Sprite.texture.get_size().x / 2

func _process(delta):
	drop_timer += delta
	position.x = clampf(
		get_global_mouse_position().x,
		position_min.position.x + position_offset,
		position_max.global_position.x - position_offset
	)

func can_drop() -> bool:
	return drop_timer >= DROP_COOLDOWN

func _unhandled_input(event):
	if event.is_action("drop_ball") && event.is_pressed() && can_drop():
		var ball_config = BallsManager.get_random_ball()
		var ball = ball_scene.instantiate()
		ball.position = position
		ball.set_configuration(ball_config)
		add_sibling(ball)
		drop_timer = 0
