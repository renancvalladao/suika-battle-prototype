extends Node2D

@onready var progress_bar = $ProgressBar

var hp = 100

func _ready():
	SignalManager.player_damaged.connect(player_damaged)
	progress_bar.value = hp

func player_damaged(damage: int) -> void:
	hp -= damage
	if hp < 0:
		hp = 0
	progress_bar.value = hp
