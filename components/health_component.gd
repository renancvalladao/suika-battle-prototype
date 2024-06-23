class_name HealthComponent
extends Node2D

@export var MAX_HEALTH := 100
@export var COLOR: Utils.AttackColors
var health: int

@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel
#signal health_is_0

const bg_colors = {
	Utils.AttackColors.RED: "#d10e00",
	Utils.AttackColors.GREEN: "#22b900",
	Utils.AttackColors.BLUE: "#399cff",
}

func _ready():
	set_health(MAX_HEALTH)
	print(bg_colors[COLOR])
	#update_color()

func set_health(value: int) -> void:
	health = value
	_update_ui()

func set_max_health(value: int) -> void:
	print(value)
	MAX_HEALTH = value
	health = value
	_update_ui()

func take_damage(damage_amount: int) -> void:
	var new_health = health - damage_amount
	new_health = clampi(new_health, 0, MAX_HEALTH)
	if new_health == 0:
		SignalManager.enemy_died.emit()
		get_parent().queue_free()
		SignalManager.health_gained.emit(5)
		
		
	set_health(new_health)

func heal(heal_amount) -> void:
	var new_health = health + heal_amount
	new_health = clampi(new_health, 0, MAX_HEALTH)
	set_health(new_health)
	
func _update_ui() -> void:
	health_label.text = str("%s/%s" % [health, MAX_HEALTH])
	health_bar.value = health
	health_bar.max_value = MAX_HEALTH
	
func update_color() -> void:
	health_bar.get("theme_override_styles/fill").bg_color = bg_colors[COLOR]
