class_name BlockBallChange
extends Debuff


func do_debuff() -> void:
	duration -= 1
	if duration == 0:
		SignalManager.can_change_next_ball.emit(true)
