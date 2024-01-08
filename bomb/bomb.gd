extends Ball

@onready var explosion_timer = $ExplosionTimer
var will_explode = false

func _on_body_entered(body):
	super._on_body_entered(body)
	if will_explode:
		return
	will_explode = true
	explosion_timer.start()

func _on_explosion_timer_timeout():
	for body in get_colliding_bodies():
		if body is Ball:
			body.queue_free()
	queue_free()
