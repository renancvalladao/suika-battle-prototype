extends Control
class_name GameTimer

var time: float = 0.0
var minutes: int = 0
var seconds: int = 0
@onready var minutes_label = $Minutes
@onready var seconds_label = $Seconds

func _process(delta) -> void:
	time += delta
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	
	minutes_label.text = "%02d:" % minutes
	seconds_label.text = "%02d" % seconds
	
func stop() -> void:
	set_process(false)
	
func get_time_formatted() -> String:
	return "%02d:$02d" % [minutes, seconds]
