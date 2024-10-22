class_name BallCanAttackComponent
extends Sprite2D

var is_damage: bool = false
var is_heal: bool = false
var is_shield: bool = false

var enemy_owner

func do_move():
	if is_damage:
		damage()
	elif is_heal:
		heal()
	else:
		shield()
		
func damage():
	enemy_owner.damage()
	
func heal():
	enemy_owner.heal()
	
func shield():
	enemy_owner.shield()
