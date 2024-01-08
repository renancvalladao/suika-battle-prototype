extends Ball

@onready var explosion_timer = $ExplosionTimer
@onready var explosion_area = $ExplosionArea

var will_explode = false

func _ready():
	super._ready()
	$ExplosionArea/ExplosionShape.scale *= config.size

func _on_body_entered(body):
	super._on_body_entered(body)
	if will_explode:
		return
	will_explode = true
	explosion_timer.start()

func _on_explosion_timer_timeout():
	for body in explosion_area.get_overlapping_bodies():
		if body is Ball:
			body.queue_free()
	queue_free()
