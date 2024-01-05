extends RigidBody2D

class_name Ball

@onready var sprite = $Sprite
@onready var icon = $Icon

var config: Dictionary = BallsManager.BALLS[0]
var exploded: bool = false

func _ready():
	$Icon.texture = config.icon
	$Icon.scale *= config.size 
	$Sprite.texture = config.sprite
	$Sprite.scale *= config.size
	$CollisionShape2D.scale *= config.size

func set_configuration(new_config: Dictionary):
	config = new_config

func explode():
	exploded = true
	queue_free()

func _on_body_entered(body):
	if config.tier == BallsManager.BALLS.size():
		return
	if body is Ball && body.config.tier == config.tier && !exploded:
		explode()
		body.explode()
		BallsManager.ball_exploded.emit(position, body.position, config.tier)
		if BallsManager.turn == 1:
			return
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
