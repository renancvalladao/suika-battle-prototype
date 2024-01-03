extends Node2D

@onready var progress_bar = $ProgressBar
@onready var shield_label = $TextureRect/ShieldLabel

var hp = 100
var shield = 0

func _ready():
	SignalManager.player_damaged.connect(player_damaged)
	SignalManager.health_gained.connect(health_gained)
	SignalManager.shield_gained.connect(shield_gained)
	progress_bar.value = hp
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
	progress_bar.value = hp

func health_gained(health: int) -> void:
	hp += health
	if hp > 100:
		hp = 100
	progress_bar.value = hp

func shield_gained(amount: int) -> void:
	shield += amount
	shield_label.text = str(shield)
