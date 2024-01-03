extends Node2D

@export var position_min: Marker2D = Marker2D.new()
@export var position_max: Marker2D = Marker2D.new()

@onready var ball_holder = $BallHolder
@onready var drop_timer = $DropTimer

var ball_scene: PackedScene = preload("res://ball/ball.tscn")
var position_offset: float = 0.0
var can_drop: bool = true

func _ready():
	position_offset = $Sprite.texture.get_size().x / 2
	add_ball_to_holder()
	BallsManager.turn_finished.connect(turn_finished)
	SignalManager.turn_started.connect(turn_started)

func _process(_delta):
	position.x = clampf(
		get_global_mouse_position().x,
		position_min.position.x + position_offset,
		position_max.global_position.x - position_offset
	)

func add_ball_to_holder() -> void:
	var ball_config = BallsManager.get_current_ball()
	var ball = ball_scene.instantiate()
	ball.process_mode = Node.PROCESS_MODE_DISABLED
	ball.set_configuration(ball_config)
	ball_holder.add_child(ball)

func _unhandled_input(event):
	if event.is_action("drop_ball") && event.is_pressed() && can_drop:
		can_drop = false
		var ball = ball_holder.get_child(0)
		ball.position = position
		ball.process_mode = Node.PROCESS_MODE_INHERIT
		ball_holder.remove_child(ball)
		add_sibling(ball)
		drop_timer.start()

func _on_drop_timer_timeout():
	can_drop = true
	BallsManager.choose_next_ball()
	add_ball_to_holder()
	BallsManager.ball_dropped.emit()

func turn_finished() -> void:
	can_drop = false

func turn_started() -> void:
	can_drop = true
