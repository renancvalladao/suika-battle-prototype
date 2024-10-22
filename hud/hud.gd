extends Control

@onready var next_ball = $NextBall
@onready var sprite: TextureRect = $NextBall/Sprite
@onready var balls_options = $BallsOptions
@onready var enemy_sprite = $NextBall/EnemySprite
@onready var enemies = $Enemies
var sprite_scale: Vector2
var enemy_scale: Vector2

@onready var experience_bar = $ExperienceBar
@onready var level = $ExperienceBar/Level
@onready var level_up_panel = $LevelUpPanel
@onready var label_level_up = $LevelUpPanel/LabelLevelUp
@onready var upgrade_options_container = $LevelUpPanel/UpgradeOptions
@onready var sound_level_up = $LevelUpPanel/SoundLevelUp

@onready var upgrade_option: PackedScene = preload("res://upgrade_system/upgrade_option.tscn")

var current_level: int = 1
var current_exp: int = 0
var collected_experience: int = 0
var exp_needed_to_lvlup: int = 10
var exp_pool:Array[int] = []

#UPGRADES
var collected_upgrades = []
var upgrade_options = []

var balls_circle_radius: float = 160.0

func _ready():
	BallsManager.next_ball_changed.connect(next_ball_changed)
	SignalManager.can_change_next_ball.connect(can_change_next_ball_ui)
	SignalManager.enemy_spawned.connect(enemy_spawned)
	#SignalManager.set_hud_exp_value.connect(on_set_hud_exp_value)
	#SignalManager.level_up.connect(on_level_up)
	#SignalManager.new_min_exp.connect(on_new_min_exp)
	#SignalManager.new_max_exp.connect(on_new_max_exp)
	SignalManager.selected_upgrade.connect(on_selected_upgrade)
	SignalManager.gain_exp.connect(on_gain_exp)
	
	set_exp_bar(0, calculate_experiencecap())
	
	var balls: Array = balls_options.get_children()
	for index in balls.size():
		var ball = balls[index]
		ball.get_child(0).texture = BallsManager.BALLS[index].sprite
		var angle = (2 * PI * index / balls.size()) - PI / 2
		var x_pos = balls_circle_radius * cos(angle)
		var y_pos = balls_circle_radius * sin(angle)
		if index < balls.size():
			ball.position = Vector2(x_pos, y_pos)

	var enemies_balls: Array = enemies.get_children()
	for index in enemies_balls.size():
		var ball = enemies_balls[index]
		#ball.get_child(0).texture = BallsManager.ENEMIES[index].sprite
		#if BallsManager.ENEMIES[index].has("preview"):
			#ball.get_child(0).texture = BallsManager.ENEMIES[index].preview
		ball.get_child(0).modulate.r = 0
		ball.get_child(0).modulate.g = 0
		ball.get_child(0).modulate.b = 0
		var angle = (2 * PI * index / enemies_balls.size()) - PI / 2
		var x_pos = balls_circle_radius * cos(angle)
		var y_pos = balls_circle_radius * sin(angle)
		if index < enemies_balls.size():
			ball.position = Vector2(x_pos, y_pos)

	sprite_scale = sprite.scale
	enemy_scale = enemy_sprite.scale
	set_next_ball()

func _process(delta):
	#if exp_pool != []:
		#print("exp_pool: ", exp_pool)
		#var gained_exp = exp_pool.pop_front()
		#calculate_experience(gained_exp)
	if collected_experience > 0:
		calculate_experience(0)

func enemy_spawned(tier: int):
	var enemies_balls: Array = enemies.get_children()
	var ball = enemies_balls[tier - 1]
	ball.get_child(0).modulate.r = 1
	ball.get_child(0).modulate.g = 1
	ball.get_child(0).modulate.b = 1

func can_change_next_ball_ui(can_change: bool) -> void:
	if !can_change:
		next_ball.modulate.a = 0.5
	else:
		next_ball.modulate.a = 1.0

func set_next_ball() -> void:
	var next_ball = BallsManager.get_next_ball()
	if (next_ball.owner == "enemy"):
		sprite.visible = false
		enemy_sprite.visible = true
		enemy_sprite.texture = next_ball.preview
		enemy_sprite.scale = enemy_scale * next_ball.size
	else:
		enemy_sprite.visible = false
		sprite.texture = next_ball.sprite
		sprite.visible = true
		sprite.scale = sprite_scale * next_ball.size

func next_ball_changed() -> void:
	set_next_ball()

#func on_set_hud_exp_value(exp_value: int):
#	experience_bar.value = exp_value

func level_up():
	sound_level_up.play()
	level.text = "Lvl. " + str(current_level)
	level_up_panel.visible = true
	var tween = level_up_panel.create_tween()
	tween.tween_property(level_up_panel, "position", Vector2(-1250,103), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	
	#var options: int = 0
	var options_max: int = 3
	for i in range(options_max):
		var option_choice = upgrade_option.instantiate()
		option_choice.upgrade = get_random_upgrade()
		upgrade_options_container.add_child(option_choice)
	
	get_tree().paused = true

func get_random_upgrade():
	var db_list = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades:
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #Don't pick up item
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			var has_all_prerequisites = true
			for prerequisite in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not prerequisite in collected_upgrades:
					has_all_prerequisites = false
			if has_all_prerequisites:
				db_list.append(i)
			else:
				pass
		else:
			db_list.append(i)
			
	if db_list.size() > 0 :
		var random_upgrade = db_list.pick_random()
		upgrade_options.append(random_upgrade)
		return random_upgrade
	else: 
		return null
		
		
		

func on_selected_upgrade(upgrade) -> void:
	var option_children = upgrade_options_container.get_children()
	for child in option_children:
		child.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	level_up_panel.visible = false
	level_up_panel.position = Vector2(500,103)
	get_tree().paused = false

func on_gain_exp(exp_gained: int) -> void:
	#print("gained_exp: ", exp_gained)
	#calculate_experience(exp_gained)
	exp_gained *= GameManager.exp_bonus_multiplier #Aplica buff de exp caso tenha
	#print(exp_gained)
	collected_experience += exp_gained
	#exp_pool.append(exp_gained)
	

func calculate_experience(exp_gained: int):
	exp_needed_to_lvlup = calculate_experiencecap()
	#print("exp needed: ", exp_needed_to_lvlup)
	#collected_experience += exp_gained
	if current_exp + collected_experience >= exp_needed_to_lvlup: #levelup
		#print("before collected_experience: ", collected_experience)
		collected_experience -= exp_needed_to_lvlup - current_exp
		#print("after collected_experience: ", collected_experience, "\n")
		
		current_level+= 1
		current_exp = 0
		exp_needed_to_lvlup = calculate_experiencecap()
		if collected_experience >= exp_needed_to_lvlup:
			exp_pool.append(collected_experience)
		level_up()
		#calculate_experience(0)
	else:
		current_exp += collected_experience
		collected_experience = 0
		
	set_exp_bar(current_exp, exp_needed_to_lvlup)
	

func calculate_experiencecap() -> int:
	var exp_cap = current_level
	if current_level < 20:
		exp_cap = current_level * 5
	elif current_level < 40:
		exp_cap = 95 + (current_level - 19) * 8
	else:
		exp_cap = 255 + (current_level - 39) * 12
	
	return exp_cap

func set_exp_bar(exp:int, max_exp:int):
	experience_bar.max_value = exp_needed_to_lvlup
	experience_bar.value = exp
	
	
#func on_new_min_exp(new_min_exp: int):
	#experience_bar.min_value = new_min_exp
	#print("exp_minvalue: ", experience_bar.min_value)
#
#func on_new_max_exp(new_max_exp: int):
	#experience_bar.max_value = new_max_exp
	#print("exp_maxvalue: ", experience_bar.max_value)
