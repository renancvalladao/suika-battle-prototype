extends Ball

class_name EnemyBall

@export var move_cooldown = 15
@export var enemy_damage: int = 40
@export var hp: int = 40

@onready var damage_numbers_origin = $DamageNumbersOrigin
@onready var health_component = $HealthComponent
@onready var animation_player = $AnimationPlayer
@onready var enemy_sprite = $Sprite
@onready var sprite_3 = $Sprite3

var cooldown = 0

func _ready():
	super._ready()
	sprite_3.texture = config.sprite
	sprite_3.scale *= config.size
	SignalManager.enemy_damaged.connect(enemy_damaged)
	Utils.AttackColors.values()
	enemy_damage += config.tier * 1
	health_component.set_max_health(GameManager.enemy_health + config.tier * 5)
	move_cooldown += config.tier * 2
	SignalManager.enemy_spawned.emit(config.tier)

func _process(delta):
	cooldown += delta
	if cooldown >= move_cooldown:
		SignalManager.turn_off_color_damage.emit()
		SignalManager.can_change_next_ball.emit(true)
		cooldown = 0
		#SignalManager.player_damaged.emit(enemy_damage)
		BallsManager.ball_exploded.emit(position, position, config.tier, config.owner)
		queue_free()
	enemy_sprite.material.set_shader_parameter("fill_percentage", cooldown / move_cooldown)

func enemy_damaged(amount: int, color: int) -> void:
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
