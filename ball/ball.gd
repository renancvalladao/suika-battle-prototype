extends RigidBody2D

class_name Ball

@onready var sprite = $Sprite
@onready var icon = $Icon
@onready var near_balls = $NearBallsArea/NearBalls
@onready var near_balls_area = $NearBallsArea

var config: Dictionary = BallsManager.BALLS[0]
var exploded: bool = false
var should_add_group: bool = true

func _ready():
	$Icon.texture = config.icon
	$Icon.scale *= config.size 
	$Sprite.texture = config.sprite
	$Sprite.scale *= config.size
	$CollisionShape2D.scale *= config.size
	near_balls.scale *= config.size
	if should_add_group:
		add_to_group("ball_%s" % config.tier)

func set_should_add_group(should: bool):
	should_add_group = should

func add_group():
	add_to_group("ball_%s" % config.tier)

func remove_group():
	remove_from_group("ball_%s" % config.tier)

func set_configuration(new_config: Dictionary):
	config = new_config

func explode():
	exploded = true
	queue_free()

func _on_body_entered(body):
	if config.tier == BallsManager.BALLS.size() || config.tier == -2:
		return
	if body is Ball && (body.config.tier == config.tier || body.config.tier == -1) && !exploded && !body.exploded:
		explode()
		body.explode()
		BallsManager.ball_exploded.emit(position, body.position, config.tier)
		if BallsManager.turn == 1:
			return
		if BallsManager.balls_effect:
			make_effect()

func make_effect():
	if config.tier == 2:
			SignalManager.shield_gained.emit(10)
	elif config.tier == 4:
		SignalManager.health_gained.emit(15)
	elif config.tier >= 6:
		SignalManager.enemy_damaged.emit(15)
	else:
		SignalManager.enemy_damaged.emit(10)

func get_nearby_balls() -> int:
	var total = 0
	for body in near_balls_area.get_overlapping_bodies():
		if body is Ball && body != self && body.config.tier != -2:
			total += 1
	return total
