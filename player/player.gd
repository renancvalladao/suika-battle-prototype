extends Node2D

@onready var progress_bar = $ProgressBar

var hp = 100

func _ready():
	SignalManager.player_damaged.connect(player_damaged)
	SignalManager.health_gained.connect(health_gained)
	progress_bar.value = hp

func player_damaged(damage: int) -> void:
	hp -= damage
	if hp < 0:
		hp = 0
	progress_bar.value = hp

func health_gained(health: int) -> void:
	hp += health
	if hp > 100:
		hp = 100
	progress_bar.value = hp
