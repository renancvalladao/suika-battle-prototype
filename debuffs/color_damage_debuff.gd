class_name ColorDamageDebuff
extends Debuff

func start_debuff() -> void:
	SignalManager.turn_on_color_damage.emit()

func do_debuff() -> void:
	duration -= 1
	if duration == 0:
		SignalManager.turn_off_color_damage.emit()
