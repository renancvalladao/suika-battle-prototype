class_name ColorDamageComponent
extends Control

@onready var label = $Label
@onready var sprite = $Sprite
@onready var icon = $Icon

var should_color_damage:bool = false
var color_damage:Array[int] = []
var enemy_turn:bool = false
var damage_amount: int

func _ready():
	SignalManager.enemy_turn_started.connect(enemy_turn_started)
	SignalManager.enemy_moved.connect(enemy_turn_finished)
	SignalManager.turn_on_color_damage.connect(turn_on_color_damage)
	SignalManager.turn_off_color_damage.connect(turn_off_color_damage)
	BallsManager.ball_exploded.connect(ball_exploded)
	visible = false
	
func enemy_turn_started() -> void:
	enemy_turn = true

func set_damage_amount(value: int) -> void:
	damage_amount = value

func enemy_turn_finished() -> void:
	enemy_turn = false

func turn_on_color_damage() -> void:
	should_color_damage = true
	var possible_colors = [0, 1, 2]
	var chosen_color = possible_colors.pick_random()
	var ball = BallsManager.BALLS[chosen_color]
	#color_damage_icon.texture = ball.icon
	sprite.texture = ball.sprite
	color_damage = [ball.tier, ball.tier + 3, ball.tier + 6]
	visible = true

	
func turn_off_color_damage() -> void:
	visible = false
	should_color_damage = false
	
func ball_exploded(_first_pos: Vector2, _second_pos: Vector2, tier: int) -> void:
	#print("explodiu, should_color_damage=",should_color_damage,", enemy_turn = ", enemy_turn, "color_damage.has(",tier,") = ", color_damage.has(tier))
	if should_color_damage && !enemy_turn && color_damage.has(tier):
		SignalManager.player_damaged.emit(damage_amount)
