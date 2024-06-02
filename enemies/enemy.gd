class_name Enemy
extends Node

@export var animation_player: AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var shield_component: ShieldComponent = $ShieldComponent
@onready var timer = $Timer

var moves: Array[String]
var move_count := 0

var my_turn := false

var debuffs: Array[Debuff] = []
@onready var intended_move = $IntendedMove


func _ready():
	SignalManager.enemy_damaged.connect(enemy_damaged)

func start_turn() -> void:
	my_turn = true
	SignalManager.enemy_turn_started.emit()
	#print(debuffs)
	if debuffs.size() > 0:
		do_debuffs()
	shield_component.reset_shield()

func finish_enemy_turn() -> void:
	my_turn = false
	SignalManager.enemy_moved.emit()

func enemy_damaged(amount: int) -> void:
	if animation_player != null:
		animation_player.play("hit_effect")
	var damage_taken: int = shield_component.take_shield_damage(amount)
	if damage_taken > 0:
		health_component.take_damage(damage_taken)
		display_damage_number(damage_taken)

func display_damage_number(damage_taken: int) -> void:
	pass

func move() -> void:
	pass
	
func do_debuffs() -> void:
	for debuff in debuffs:
		debuff.do_debuff()
		if debuff.duration <= 0:
			debuffs.erase(debuff)
	
func damage() -> void:
	pass

func heal() -> void:
	pass
	
func shield() -> void:
	pass
