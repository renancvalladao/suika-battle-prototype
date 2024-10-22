extends Ball

class_name EnemyBall

@export var move_cooldown = 15
@export var enemy_damage: int = 40
@export var hp: int = 40
@export var kill_exp:int = 5

@onready var damage_numbers_origin = $DamageNumbersOrigin
@onready var health_component = $HealthComponent
@onready var animation_player = $AnimationPlayer
@onready var enemy_sprite = $Sprite
@onready var animated_sprite_2d = $AnimatedSprite2D

var cooldown = 0
var can_take_damage = true
var tween
var initial_shake_cooldown = 2
var shake_cooldown = initial_shake_cooldown
var shake_intensity = 3
var min_shake_cooldown = 0.05

func _ready():
	super._ready()
	SignalManager.enemy_damaged.connect(enemy_damaged)
	enemy_damage += config.tier * 1
	health_component.set_max_health(GameManager.enemy_health + config.tier * 25)
	move_cooldown += config.tier * 5
	health_component.kill_exp = abs(kill_exp * config.tier)
	SignalManager.enemy_spawned.emit(config.tier)
	if config.has("animation"):
		animated_sprite_2d.sprite_frames = config.animation
		if config.has("sprite_scale"):
			animated_sprite_2d.scale = Vector2(config.sprite_scale, config.sprite_scale)
		animated_sprite_2d.scale *= config.size
		animated_sprite_2d.play("default")
		animated_sprite_2d.show()
		enemy_sprite.hide()

func _process(delta):
	cooldown += delta
	shake_cooldown -= delta

	if shake_cooldown <= 0:
		var new_shake_cooldown = (1 - (cooldown / move_cooldown)) * initial_shake_cooldown
		shake_cooldown = max(min_shake_cooldown, new_shake_cooldown)
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.set_parallel(true)
		var random_offset_x = randf_range(-shake_intensity, shake_intensity)
		var random_offset_y = randf_range(-shake_intensity, shake_intensity)
		tween.tween_property(animated_sprite_2d, "position", animated_sprite_2d.position + Vector2(random_offset_x, random_offset_y), shake_cooldown / 3).set_ease(Tween.EASE_OUT)
		tween.tween_property(animated_sprite_2d, "position", animated_sprite_2d.position, shake_cooldown / 3).set_ease(Tween.EASE_OUT).set_delay(shake_cooldown / 3)

	if cooldown >= move_cooldown:
		SignalManager.turn_off_color_damage.emit()
		SignalManager.can_change_next_ball.emit(true)
		cooldown = 0
		BallsManager.ball_exploded.emit(position, position, config.tier, config.owner)
		if tween:
			tween.kill()
		queue_free()
	#enemy_sprite.material.set_shader_parameter("fill_percentage", cooldown / move_cooldown)

func enemy_damaged(amount: int, should_multiplier_apply: bool) -> void:
	if !can_take_damage:
		return
	var is_critical := false
	if animation_player != null:
		animation_player.play("hit_effect")
	if amount > 0:
		if should_multiplier_apply:
			amount *= GameManager.damage_buff_multiplier # Aplica buff de dano caso tenha
		health_component.take_damage(amount)
		display_damage_number(amount, is_critical)
		if GameManager.reduce_enemyprogress_on_damage > 0:
			cooldown -= GameManager.reduce_enemyprogress_on_damage
	else:
		health_component.take_damage(0)

func display_damage_number(amount: int, is_critical: bool) -> void:
	DamageNumbers.display_number(amount, damage_numbers_origin.global_position, is_critical)

func set_should_add_group(should: bool):
	super.set_should_add_group(should)
	can_take_damage = false

func add_group():
	super.add_group()
	can_take_damage = true
