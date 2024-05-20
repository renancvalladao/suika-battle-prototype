extends Control
class_name ChangeColorComponent

@onready var current_color_texture = $CurrentColor
@onready var future_color_texture = $FutureColor
@onready var label = $Label

var current_color_number := 0
var future_color_number := 0

func set_current_color(color: int) -> void:
	current_color_number = color
	current_color_texture.texture = BallsManager.BALLS[color - 1].sprite
	
func set_future_color(color: int) -> void:
	future_color_number = color
	future_color_texture.texture = BallsManager.BALLS[color - 1].sprite

func choose_random_colors() -> void:
	var possible_colors :Array[int] = [1,2,3] #1 == vermelho, 2 == verde, 3 == azul
	var chosen_color = possible_colors.pick_random()
	set_current_color(chosen_color)
	
	possible_colors.erase(chosen_color)
	chosen_color = possible_colors.pick_random()
	set_future_color(chosen_color)

func change_color() -> void:
	print("entrou")
	var current_color_tiers = [current_color_number, current_color_number + 3, current_color_number + 6]
	var future_color_tiers = [future_color_number, future_color_number + 3, future_color_number + 6]
	
	for color in current_color_tiers:
		var color_string: String = "ball_" + str(color)
		print(color_string)
		get_tree().call_group(color_string,"change_color", current_color_tiers, future_color_tiers)
		
	for color in future_color_tiers:
		var color_string: String = "ball_" + str(color)
		get_tree().call_group(color_string,"change_color", future_color_tiers, current_color_tiers)
