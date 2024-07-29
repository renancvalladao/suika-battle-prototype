extends Ball

class_name EnemyBall

@export var move_cooldown = 15
@export var enemy_damage: int = 40
@export var hp: int = 40

@onready var damage_numbers_origin = $DamageNumbersOrigin
@onready var health_component = $HealthComponent
@onready var animation_player = $AnimationPlayer
@onready var enemy_sprite = $Sprite

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
	Utils.AttackColors.values()
	enemy_damage += config.tier * 1
	health_component.set_max_health(GameManager.enemy_health + config.tier * 25)
	move_cooldown += config.tier * 5
	SignalManager.enemy_spawned.emit(config.tier)

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
		tween.tween_property(enemy_sprite, "position:x", enemy_sprite.position.x - shake_intensity, shake_cooldown / 3).set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy_sprite, "position:x", enemy_sprite.position.x + shake_intensity, shake_cooldown / 3).set_ease(Tween.EASE_OUT).set_delay(shake_cooldown / 3)
		tween.tween_property(enemy_sprite, "position:x", enemy_sprite.position.x, shake_cooldown / 3).set_ease(Tween.EASE_OUT).set_delay(shake_cooldown / 3)

	if cooldown >= move_cooldown:
		SignalManager.turn_off_color_damage.emit()
		SignalManager.can_change_next_ball.emit(true)
		cooldown = 0
		#SignalManager.player_damaged.emit(enemy_damage)
		BallsManager.ball_exploded.emit(position, position, config.tier, config.owner)
		EnemyVisualEffects.display_evolution(damage_numbers_origin.global_position, config.size)
		if tween:
			tween.kill()
		queue_free()
	#enemy_sprite.material.set_shader_parameter("fill_percentage", cooldown / move_cooldown)

func enemy_damaged(amount: int, color: int) -> void:
	if !can_take_damage:
		return
	var is_critical := false
	if animation_player != null:
		animation_player.play("hit_effect")
	if amount > 0:
		health_component.take_damage(amount)
		display_damage_number(amount, is_critical)
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
