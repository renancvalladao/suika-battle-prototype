extends Control

@onready var next_ball = $NextBall
@onready var sprite: TextureRect = $NextBall/Sprite
@onready var icon = $NextBall/Icon
@onready var add_mana_button = $AddManaButton
@onready var balls_options = $BallsOptions
@onready var add_health_button = $AddHealthButton
@onready var red_label = $BallsCounter/RedBalls/Label
@onready var green_label = $BallsCounter/GreenBalls/Label
@onready var blue_label = $BallsCounter/BlueBalls/Label
@onready var enemy_sprite = $NextBall/EnemySprite
@onready var enemies = $Enemies
var sprite_scale: Vector2
var enemy_scale: Vector2

@onready var experience_bar = $ExperienceBar
@onready var level = $ExperienceBar/Level

func _ready():
	BallsManager.next_ball_changed.connect(next_ball_changed)
	SignalManager.can_change_next_ball.connect(can_change_next_ball_ui)
	SignalManager.enemy_spawned.connect(enemy_spawned)
	SignalManager.set_hud_exp_value.connect(on_set_hud_exp_value)
	SignalManager.level_up.connect(on_level_up)
	SignalManager.new_min_exp.connect(on_new_min_exp)
	SignalManager.new_max_exp.connect(on_new_max_exp)
	add_mana_button.pressed.connect(on_add_mana)
	add_health_button.pressed.connect(on_add_health)
	
	experience_bar.value = 0
	var balls: Array = balls_options.get_children()
	for index in balls.size():
		var ball = balls[index]
		ball.get_child(0).texture = BallsManager.BALLS[index].sprite
		ball.get_child(1).texture = BallsManager.BALLS[index].icon
		ball.get_child(1).visible = false
	var enemies_balls: Array = enemies.get_children()
	for index in enemies_balls.size():
		var ball = enemies_balls[index]
		ball.get_child(0).texture = BallsManager.ENEMIES[index].sprite
		ball.get_child(0).modulate.r = 0
		ball.get_child(0).modulate.g = 0
		ball.get_child(0).modulate.b = 0
	sprite_scale = sprite.scale
	enemy_scale = enemy_sprite.scale
	set_next_ball()

func enemy_spawned(tier: int):
	var enemies_balls: Array = enemies.get_children()
	var ball = enemies_balls[tier - 1]
	ball.get_child(0).modulate.r = 1
	ball.get_child(0).modulate.g = 1
	ball.get_child(0).modulate.b = 1

#func _process(_delta):
	#red_label.text = "%s" % get_balls_by_color("red")
	#green_label.text = "%s" % get_balls_by_color("green")
	#blue_label.text = "%s" % get_balls_by_color("blue")
	
func can_change_next_ball_ui(can_change: bool) -> void:
	if !can_change:
		next_ball.modulate.a = 0.5
	else:
		next_ball.modulate.a = 1.0

func get_balls_by_color(color: String) -> int:
	var tiers = []
	if color == "red":
		tiers = [1, 4, 7]
	elif color == "green":
		tiers = [2, 5, 8]
	else:
		tiers = [3, 6, 9]
	var total = 0
	for tier in tiers:
		total += get_tree().get_nodes_in_group("ball_%s" % tier).size()
	return total

func set_next_ball() -> void:
	var next_ball = BallsManager.get_next_ball()
	if (next_ball.owner == "enemy"):
		#icon.visible = false
		sprite.visible = false
		enemy_sprite.visible = true
		enemy_sprite.texture = next_ball.sprite
		enemy_sprite.scale = enemy_scale * next_ball.size
	else:
		enemy_sprite.visible = false
		sprite.texture = next_ball.sprite
		icon.texture = next_ball.icon
		#icon.visible = true
		sprite.visible = true
		sprite.scale = sprite_scale * next_ball.size

func next_ball_changed() -> void:
	set_next_ball()

func on_add_mana():
	SignalManager.mana_gained.emit(100)

func on_add_health():
	SignalManager.health_gained.emit(100)
	
#func on_gain_exp(exp: int):
	#experience_bar.value += exp
	#print("exp_value: ", experience_bar.value)
	
func on_set_hud_exp_value(exp: int):
	experience_bar.value = exp

func on_level_up(new_level: int):
	level.text = "Lvl. " + str(new_level)

func on_new_min_exp(new_min_exp: int):
	experience_bar.min_value = new_min_exp
	print("exp_minvalue: ", experience_bar.min_value)

func on_new_max_exp(new_max_exp: int):
	experience_bar.max_value = new_max_exp
	print("exp_maxvalue: ", experience_bar.max_value)
