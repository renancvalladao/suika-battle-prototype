extends Node2D

@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel
@onready var shield_label = $TextureRect/ShieldLabel

var hp = 100
var shield = 0

func _ready():
	SignalManager.player_damaged.connect(player_damaged)
	SignalManager.health_gained.connect(health_gained)
	SignalManager.shield_gained.connect(shield_gained)
	update_health_ui(hp)
	shield_label.text = str(shield)

func player_damaged(damage: int) -> void:
	shield -= damage
	if shield < 0:
		damage = -1 * shield
		shield = 0
	else:
		damage = 0
	hp -= damage
	if hp <= 0:
		hp = 0
		SignalManager.on_game_over.emit()
	shield_label.text = str(shield)
	update_health_ui(hp)

func health_gained(health: int) -> void:
	hp += health
	if hp > 100:
		hp = 100
	update_health_ui(hp)

func shield_gained(amount: int) -> void:
	shield += amount
	shield_label.text = str(shield)

func update_health_ui(new_hp: int) -> void:
	health_bar.value = hp
	health_label.text = str("%s/100" % hp)
	
