class_name BlockBallChange
extends Debuff


func start_debuff() -> void:
	SignalManager.can_change_next_ball.emit(false)

func do_debuff() -> void:
	duration -= 1
	if duration == 0:
		SignalManager.can_change_next_ball.emit(true)
