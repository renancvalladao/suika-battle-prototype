extends Node

signal player_damaged(damage: int)
signal turn_started
signal spawn_random_ball
signal enemy_damaged(damage: int)
signal health_gained(health: int)
signal shield_gained(amount: int)
signal on_game_over
signal explode_ball_tier(tier: int)
signal enemy_moved
signal mana_gained(amount: int)
signal all_balls_dropped()
signal balls_left_gained(amount: int)

signal can_change_next_ball(can_change: bool)
