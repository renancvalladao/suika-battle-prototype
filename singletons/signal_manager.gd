extends Node

signal player_damaged(damage: int)
signal turn_started
signal spawn_random_ball

signal health_gained(health: int)
signal shield_gained(amount: int)
signal on_game_over
signal explode_ball_tier(tier: int)

signal mana_gained(amount: int)
signal all_balls_dropped()
signal balls_left_gained(amount: int)

signal can_change_next_ball(can_change: bool)
signal is_dropping()

#===========Enemy===========
signal enemy_damaged(damage: int, damage_color: int)
signal enemy_moved
signal enemy_turn_started
signal enemy_move_delayed(amount: int)
signal enemy_died
signal enemy_spawned(tier: int)
signal create_explosion(position: Vector2)

#===========Debuffs===========
signal turn_on_color_damage
signal turn_off_color_damage


#===========Exp and Upgrades=============
signal gain_exp(exp: int)
signal set_hud_exp_value(exp: int)
signal level_up(new_level: int)
signal new_max_exp(max_exp: int)
signal new_min_exp(min_exp: int)
signal selected_upgrade(upgrade)
