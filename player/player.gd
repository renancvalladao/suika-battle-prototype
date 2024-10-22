extends Node2D

@export_group("Player Actions")
@export var ATTACK_DAMAGE = 10

@export_group("Upgrades")
@export var damage_buff_multiplier_increase_per_level = 0.1
@export var exp_bonus_multiplier_increase_per_level = 0.1
@export var reduce_enemyprogress_on_damage_per_level = 0.5
@export var ghost_ball_spawn_chance_per_level = 0.05
@export var rainbow_ball_spawn_chance_per_level = 0.05
@export var bomb_ball_spawn_chance_per_level = 0.05
@export var bow_damage = 50

func _ready():
	BallsManager.ball_exploded.connect(on_ball_exploded)
	SignalManager.selected_upgrade.connect(upgrade_character)

func upgrade_character(upgrade) -> void:
	match upgrade:
		"damage_buff1","damage_buff2","damage_buff3","damage_buff4","damage_buff5":
			GameManager.damage_buff_multiplier += damage_buff_multiplier_increase_per_level
		"exp_bonus1","exp_bonus2","exp_bonus3","exp_bonus4","exp_bonus5":
			GameManager.exp_bonus_multiplier += exp_bonus_multiplier_increase_per_level
		"slow_enemy_evolution1","slow_enemy_evolution2","slow_enemy_evolution3","slow_enemy_evolution4","slow_enemy_evolution5":
			GameManager.reduce_enemyprogress_on_damage += reduce_enemyprogress_on_damage_per_level
		"ghost_ball1","ghost_ball2","ghost_ball3","ghost_ball4","ghost_ball5":
			GameManager.spawn_chance_ghost_ball += ghost_ball_spawn_chance_per_level
		"rainbow_ball1","rainbow_ball2","rainbow_ball3","rainbow_ball4","rainbow_ball5":
			GameManager.spawn_chance_rainbow_ball += rainbow_ball_spawn_chance_per_level
		"bomb_ball1","bomb_ball2","bomb_ball3","bomb_ball4","bomb_ball5":
			GameManager.spawn_chance_bomb_ball += bomb_ball_spawn_chance_per_level
		"bow":
			SignalManager.enemy_damaged.emit(bow_damage, false)

func on_ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int, owner: String):
	if owner == "enemy":
		return
	SignalManager.enemy_damaged.emit(ATTACK_DAMAGE * tier, true)

func _on_timer_timeout(): # Timer de teste de xp só
	#SignalManager.gain_exp.emit(5)
	#SignalManager.gain_exp.emit(10)
	pass
