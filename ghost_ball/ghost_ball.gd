extends Ball

var ATTACK_DAMAGE = 5

func _on_body_entered(body):
	if body is EnemyBall:
		body.enemy_damaged(ATTACK_DAMAGE * config.tier, true)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
