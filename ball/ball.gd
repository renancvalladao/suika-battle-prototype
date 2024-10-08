extends RigidBody2D

class_name Ball

@onready var sprite = $Sprite
@onready var icon = $Icon
@onready var near_balls = $NearBallsArea/NearBalls
@onready var near_balls_area = $NearBallsArea
@onready var near_range = $NearBallsArea/Range
@onready var near_balls_label = $NearBallsLabel
@onready var change_timer = $ChangeTimer
@onready var ball_can_attack_component = $BallCanAttackComponent

var config: Dictionary = BallsManager.BALLS[0]
var exploded: bool = false
var should_add_group: bool = true
var added_to_balls_group: bool = false
var can_change_color: bool = true

var initial_icon_scale: Vector2
var initial_sprite_scale: Vector2
var initial_collision2d_scale: Vector2
var initial_near_balls_scale: Vector2
var initial_near_range_scale: Vector2

func _ready():
	set_initial_scales()
	$Icon.texture = config.icon
	$Icon.scale *= config.size 
	$Sprite.texture = config.sprite
	$Sprite.scale *= config.size
	$CollisionShape2D.scale *= config.size
	near_balls.scale *= config.size
	near_range.scale *= config.size
	ball_can_attack_component.visible = false
	
	if should_add_group:
		add_to_group("ball_%s" % config.tier)
		var tween = get_tree().create_tween()
		scale = Vector2.ZERO
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_IN)
		
func set_initial_scales() -> void:
	initial_icon_scale = $Icon.scale
	initial_sprite_scale = $Sprite.scale
	initial_collision2d_scale = $CollisionShape2D.scale
	initial_near_balls_scale = near_balls.scale
	initial_near_range_scale = near_range.scale
	
func reset_scales() -> void:
	$Icon.scale = initial_icon_scale
	$Sprite.scale = initial_sprite_scale
	$CollisionShape2D.scale = initial_collision2d_scale
	near_balls.scale = initial_near_balls_scale
	near_range.scale = initial_near_range_scale

func set_should_add_group(should: bool):
	should_add_group = should

func add_group():
	#add_to_group("balls")
	add_to_group("ball_%s" % config.tier)

func remove_group():
	remove_from_group("ball_%s" % config.tier)

func set_configuration(new_config: Dictionary):
	config = new_config

func explode():
	exploded = true
	if ball_can_attack_component.visible:
		ball_can_attack_component.do_move()
	queue_free()

func _on_body_entered(body):
	#print("colidiu")
	if config.tier == -2:
		return
	if config.tier == -1 && not (body is Ball):
		queue_free()
	if config.has("type") && body is Ball:
		if config.type == "ghost" && config.tier != body.config.tier:
			#print("entrou")
			return
		
	if body is Ball && (body.config.tier == config.tier || body.config.tier == -1) && !exploded && !body.exploded:
		if (config.owner != body.config.owner) && body.config.tier != -1:
			return
		explode()
		body.explode()
		BallsManager.ball_exploded.emit(position, body.position, config.tier, config.owner)
		if BallsManager.turn == 1:
			return
		if BallsManager.balls_effect:
			make_effect()
		if body is EnemyBall:
			return
		if !GameManager.range_damage:
			return
		var scale_factor: int = ((config.tier - 1) / 3) + 1
		var color := Utils.AttackColors.RED
		for near_ball in near_balls_area.get_overlapping_bodies():
			if near_ball is EnemyBall:
				near_ball.enemy_damaged(5 * scale_factor, color)

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

func _process(_delta):
	if near_balls_label.visible:
		near_balls_label.text = str(get_nearby_balls())

func _on_mouse_entered():
	if GameManager.character_chosen == GameManager.CHARACTER.AREA:
		near_balls_label.visible = true
		near_range.visible = true

func _on_mouse_exited():
	near_balls_label.visible = false
	near_range.visible = false
	
func change_color(current_color_tiers, future_color_tiers):
	if !can_change_color:
		return
		
	can_change_color = false
	change_timer.start()
	
	var my_tier :int = config.tier
	var my_tier_index :int = current_color_tiers.find(my_tier)
	remove_group()
	
	var new_tier :int = future_color_tiers[my_tier_index]
	var new_config: Dictionary = BallsManager.BALLS[new_tier - 1]
	#print("my_tier:", my_tier , "new_tier", new_tier)
	config = new_config
	update_config()
	add_group()
	
func set_can_change_color_to_true() -> void :
	can_change_color = true

	
func update_config() -> void:
	reset_scales()
	$Icon.texture = config.icon
	$Icon.scale *= config.size 
	$Sprite.texture = config.sprite
	$Sprite.scale *= config.size
	$CollisionShape2D.scale *= config.size
	near_balls.scale *= config.size
	near_range.scale *= config.size

func change_tier(new_tier: int) -> void:
	#var my_tier :int = config.tier
	remove_group()
	var new_config: Dictionary = BallsManager.BALLS[new_tier - 1]
	config = new_config
	update_config()
	add_group()
	

func _on_change_timer_timeout():
	if !added_to_balls_group:
		add_to_group("balls")
		added_to_balls_group = true
	set_can_change_color_to_true()
