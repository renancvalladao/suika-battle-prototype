extends Node

enum CHARACTER {QUANTITY, FUSION, AREA, ALL}

var character_chosen: CHARACTER = CHARACTER.QUANTITY
var fusions: int = 0
var max_balls: int = 999
var max_actions: int = 999
var bar_color_damage_multiplier = 1.5
