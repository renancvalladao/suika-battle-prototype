extends Node

var fusions: int = 0
var max_balls: int = 999
var max_actions: int = 999

var balls_per_enemy := 6
var enemy_health := 30
var range_damage := false
var auto_enemy := false

#BUFFS/MULTIPLIERS
var bar_color_damage_multiplier = 2
var damage_buff_multiplier:float = 1.0
var exp_bonus_multiplier: float = 1.0
var reduce_enemyprogress_on_damage:float = 0.0
var spawn_chance_ghost_ball: float = 0.0
var spawn_chance_rainbow_ball: float = 0.0
var spawn_chance_bomb_ball: float = 0.0
