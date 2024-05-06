class_name ShieldComponent
extends Node2D


@export var MAX_SHIELD := 999
var shield: int
@onready var shield_label = $TextureRect/ShieldLabel

func _ready():
	set_shield(0)

func set_shield(value: int) -> void:
	shield = value
	_update_ui()
	
func take_shield_damage(damage_amount: int) -> int:
	var new_shield: int = shield - damage_amount
	var damage_taken: int = 0
	if new_shield < 0:
		damage_taken = abs(new_shield)
	
	new_shield = clampi(new_shield, 0, MAX_SHIELD)
	set_shield(new_shield)
	
	return damage_taken

func gain_shield(shield_amount: int) -> void:
	var new_shield: int = shield + shield_amount
	new_shield = clampi(new_shield, 0, MAX_SHIELD)
	set_shield(new_shield)
	
	if !visible:
		visible = true
		
func reset_shield() -> void:
	set_shield(0)
		
func _update_ui() -> void:
	shield_label.text = str(shield)
	if shield == 0:
		visible = false
	
