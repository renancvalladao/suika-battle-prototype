extends Node2D

const ATTACK_MANA = 20
const SHIELD_MANA = 15
const HEAL_MANA = 20
const HEAL_AMOUNT = 10
const GHOST_BALL_MANA = 50
const EXPLODE_MANA = 50
const RAINBOW_MANA = 50
const MAX_REFRESH = 1

@export_group("Player Actions")
@export var ATTACK_AMOUNT = 1
@export var SHIELD_AMOUNT = 1
@export var EXTRA_BALLS_AMOUNT = 1
@export var AUTO_ATTACK_AMOUNT = 10
@export var AUTO_SHIELD_AMOUNT = 10
@export var AUTO_ACCELERATION_AMOUNT = 5

@export_group("Player Status")
@export var max_hp = 100

var CHAOS_AMOUNT = EXTRA_BALLS_AMOUNT
@onready var health_bar = $HealthBar
@onready var health_label = $HealthBar/HealthLabel
@onready var mana_bar = $ManaBar
@onready var mana_label = $ManaBar/ManaLabel
@onready var shield_label = $TextureRect/ShieldLabel
@onready var chain_explosion_timer = $ChainExplosionTimer
@onready var attack_button = $VBoxContainer/AttackButton
@onready var shield_button = $VBoxContainer/ShieldButton
@onready var heal_button = $VBoxContainer/HealButton
@onready var ghost_ball_button = $VBoxContainer/GhostBallButton
@onready var ghost_ball_sprite = $VBoxContainer/GhostBallButton/SelectedBall/Sprite
@onready var ghost_ball_icon = $VBoxContainer/GhostBallButton/SelectedBall/Icon
@onready var explode_button = $VBoxContainer/ExplodeButton
@onready var explode_sprite = $VBoxContainer/ExplodeButton/SelectedBall/Sprite
@onready var explode_icon = $VBoxContainer/ExplodeButton/SelectedBall/Icon
@onready var rainbow_button = $VBoxContainer/RainbowButton
@onready var lifesteal_button = $VBoxContainer/LifestealButton
@onready var chaos_button = $VBoxContainer/ChaosButton
@onready var actions_left_label = $VBoxContainer/ActionsLeftLabel
@onready var end_turn_button = $VBoxContainer/EndTurnButton
@onready var attack_refresh = $AttackRefresh
@onready var defense_refresh = $DefenseRefresh
@onready var acceleration_refresh = $AccelerationRefresh
@onready var attack_bar = $AttackBar
@onready var shield_bar = $ShieldBar
@onready var acceleration_bar = $AccelerationBar
@onready var attack_bar_player = $AttackBar/AttackBarPlayer
@onready var shield_bar_player = $ShieldBar/ShieldBarPlayer
@onready var acceleration_bar_player = $AccelerationBar/AccelerationBarPlayer

var action_tiers = {
	"attack": 1,
	"shield": 1,
	"chaos": 1
}
var hp = 0
var mana = 0
var shield = 0
var explosion_chain = false
var selected_ball = 0
var rainbown_config: Dictionary = {
	"tier": -1,
	"sprite": preload("res://assets/balls/black_body_circle.png"),
	"icon": preload("res://assets/icons/crown.png"),
	"size": 1
}
var first_turn = true
var actions_left = GameManager.max_actions
var my_turn = false
var current_refresh_count = MAX_REFRESH

var level: int = 1
var current_exp: int = 0
var exp_needed_to_lvlup: int = 10
var leveling_up: bool = false
#@onready var upgrade_options: PackedScene = preload("res://upgrade_system/upgrade_option.tscn")

@export_group("Upgrades")
@export var damage_buff_multiplier_increase_per_level = 0.1
@export var exp_bonus_multiplier_increase_per_level = 0.1
@export var reduce_enemyprogress_on_damage_per_level = 0.5
@export var ghost_ball_spawn_chance_per_level = 0.05
@export var rainbow_ball_spawn_chance_per_level = 0.05
@export var bomb_ball_spawn_chance_per_level = 0.05
@export var bow_damage = 50

func _ready():
	hp = max_hp
	health_bar.max_value = max_hp
	SignalManager.player_damaged.connect(player_damaged)
	SignalManager.health_gained.connect(health_gained)
	SignalManager.shield_gained.connect(shield_gained)
	BallsManager.ball_exploded.connect(ball_exploded)
	#BallsManager.turn_finished.connect(turn_finished)
	#SignalManager.turn_started.connect(turn_started)
	SignalManager.turn_started.connect(pick_random_actions_tier)
	SignalManager.turn_started.connect(reset_refresh_count)
	SignalManager.all_balls_dropped.connect(enable_end_turn)
	attack_button.text = "Attack 1 (%s)" % [ATTACK_AMOUNT]
	attack_button.pressed.connect(on_attack_pressed)
	shield_button.text = "Defense 1 (%s)" % [SHIELD_AMOUNT]
	shield_button.pressed.connect(on_shield_pressed)
	heal_button.text = "Buff 1 (%s)" % [HEAL_AMOUNT]
	heal_button.pressed.connect(on_health_pressed)
	ghost_ball_button.text = "%s - Ghost Ball" % GHOST_BALL_MANA
	ghost_ball_button.pressed.connect(on_ghost_ball_pressed)
	explode_button.text = "%s - Explode" % EXPLODE_MANA
	explode_button.pressed.connect(on_explode_press)
	rainbow_button.text = "%s - Rainbow" % RAINBOW_MANA
	rainbow_button.pressed.connect(on_rainbow_press)
	lifesteal_button.text = "Lifesteal 1"
	lifesteal_button.pressed.connect(on_lifesteal_press)
	chaos_button.text = "+Balls 1 (%s)" % CHAOS_AMOUNT
	chaos_button.pressed.connect(on_chaos_press)
	update_health_ui(hp)
	#update_mana_ui(mana)
	shield_label.text = str(shield)
	ghost_ball_sprite.texture = BallsManager.BALLS[selected_ball].sprite
	ghost_ball_icon.texture = BallsManager.BALLS[selected_ball].icon
	explode_sprite.texture = BallsManager.BALLS[selected_ball].sprite
	explode_icon.texture = BallsManager.BALLS[selected_ball].icon
	SignalManager.mana_gained.connect(mana_gained)
	actions_left_label.text = "Actions Left: %s" % actions_left
	end_turn_button.pressed.connect(on_end_turn_press)
	attack_refresh.pressed.connect(func(): refresh_action("attack"))
	defense_refresh.pressed.connect(func(): refresh_action("shield"))
	acceleration_refresh.pressed.connect(func(): refresh_action("chaos"))
	attack_bar.value = 0
	shield_bar.value = 0
	acceleration_bar.value = 0
	BallsManager.ball_exploded.connect(on_ball_exploded)
	#SignalManager.gain_exp.connect(on_gain_exp)
	#SignalManager.new_min_exp.emit(current_exp)
	#SignalManager.new_max_exp.emit(exp_needed_to_lvlup)
	SignalManager.selected_upgrade.connect(upgrade_character)

func refresh_action(action: String):
	var current_tier = action_tiers[action]
	var possible_tiers = [1, 2, 3]
	possible_tiers.erase(current_tier)
	var next_tier = possible_tiers.pick_random()
	action_tiers[action] = next_tier
	current_refresh_count -= 1


func upgrade_character(upgrade) -> void:
	match upgrade:
		"damage_buff1","damage_buff2","damage_buff3","damage_buff4","damage_buff5":
			GameManager.damage_buff_multiplier += damage_buff_multiplier_increase_per_level
		"exp_bonus1","exp_bonus2","exp_bonus3","exp_bonus4","exp_bonus5":
			GameManager.exp_bonus_multiplier += exp_bonus_multiplier_increase_per_level
		"slow_enemy_evolution1","slow_enemy_evolution2","slow_enemy_evolution3","slow_enemy_evolution4","slow_enemy_evolution5":
			GameManager.reduce_enemyprogress_on_damage += reduce_enemyprogress_on_damage_per_level
		"ghost_ball1","ghost_ball2","ghost_ball3","ghost_ball4","ghost_ball5":
			GameManager.spawn_chance_ghost_ball += ghost_ball_spawn_chance_per_level
		"rainbow_ball1","rainbow_ball2","rainbow_ball3","rainbow_ball4","rainbow_ball5":
			GameManager.spawn_chance_rainbow_ball += rainbow_ball_spawn_chance_per_level
		"bomb_ball1","bomb_ball2","bomb_ball3","bomb_ball4","bomb_ball5":
			GameManager.spawn_chance_bomb_ball += bomb_ball_spawn_chance_per_level
		"bow":
			SignalManager.enemy_damaged.emit(bow_damage, 0, false)


func on_ball_exploded(first_pos: Vector2, second_pos: Vector2, tier: int, owner: String):
	if owner == "enemy":
		return
	var increment = 20
	var scale_factor: int = ((tier - 1) / 3) + 1
	var color := Utils.AttackColors.RED
	if GameManager.range_damage:
			return
	SignalManager.enemy_damaged.emit(AUTO_ATTACK_AMOUNT * tier, color, true)
	return
	var action = null
	var bar = null
	var bar_player = null
	#var color:Utils.AttackColors
	if (tier == 1 || tier == 4 || tier == 7):
		bar = attack_bar
		action = "attack"
		bar_player = attack_bar_player
		color = Utils.AttackColors.RED
	if (tier == 2 || tier == 5 || tier == 8):
		bar = shield_bar
		action = "shield"
		bar_player = shield_bar_player
		color = Utils.AttackColors.GREEN
	if (tier == 3 || tier == 6 || tier == 9):
		bar = acceleration_bar
		action = "acceleration"
		bar_player = acceleration_bar_player
		color = Utils.AttackColors.BLUE
	if (bar != null && action != null):
		var new_value = bar.value + increment * scale_factor
		bar.value = new_value
		bar_player.play("on_" + action + "_increase")
		if new_value >= bar.max_value:
			bar.value = new_value - bar.max_value
			SignalManager.enemy_damaged.emit(AUTO_ATTACK_AMOUNT, color)

func reset_refresh_count():
	current_refresh_count = MAX_REFRESH

func on_end_turn_press():
	BallsManager.turn_finished.emit()
	end_turn_button.disabled = true
	my_turn = false

func enable_end_turn():
	end_turn_button.disabled = false

func update_actions_left(value: int) -> void:
	actions_left = value
	actions_left_label.text = "Actions Left: %s" % actions_left

func pick_random_actions_tier():
	my_turn = true
	end_turn_button.disabled = true
	shield = 0
	shield_label.text = str(shield)
	update_actions_left(GameManager.max_actions)
	if first_turn:
		first_turn = false
		return
	for key in action_tiers.keys():
		var current_tier = action_tiers[key]
		#var possible_tiers = [1, 2, 3]
		#possible_tiers.erase(current_tier)
		#var next_tier = possible_tiers.pick_random()
		action_tiers[key] = max(1, current_tier - 1)

func mana_gained(amount: int):
	mana += amount
	if mana > 100:
		mana = 100
	#update_mana_ui(mana)

#func _process(_delta):
	#var is_refresh_enabled = false
	#attack_refresh.disabled = !is_refresh_enabled && !my_turn
	#attack_refresh.visible = is_refresh_enabled && my_turn
	#defense_refresh.disabled = !is_refresh_enabled && !my_turn
	#defense_refresh.visible = is_refresh_enabled && my_turn
	#acceleration_refresh.disabled = !is_refresh_enabled && !my_turn
	#acceleration_refresh.visible = is_refresh_enabled && my_turn
	#check_attack_enabled()
	#var red_balls = get_balls_by_color("red")
	#var current_attack_amount: int = ATTACK_AMOUNT * action_tiers.attack * red_balls
	#attack_button.text = "Attack %s (%s)" % [action_tiers.attack, current_attack_amount]
	#check_defense_enabled()
	#var green_balls = get_balls_by_color("green")
	#var current_defense_amount: int = SHIELD_AMOUNT * action_tiers.shield * green_balls
	#shield_button.text = "Defense %s (%s)" % [action_tiers.shield, current_defense_amount]
	##check_buff_enabled()
	##check_lifesteal_enabled()
	#check_chaos_enabled()
	#var blue_balls = get_balls_by_color("blue")
	#var current_extra_balls_amount: int = CHAOS_AMOUNT * action_tiers.chaos * blue_balls
	#chaos_button.text = "+Balls %s (%s)" % [action_tiers.chaos, current_extra_balls_amount]

func check_chaos_enabled():
	#var first_tiers = [1, 2, 3]
	if actions_left <= 0 || !my_turn:
		chaos_button.disabled = true
		return
	var first_tiers = [3]
	var tiers = [action_tiers.chaos]
	for tier in tiers:
		chaos_button.text = "+Balls %s (%s)" % [tier, CHAOS_AMOUNT * tier]
		var enabled: Array = []
		for first_tier in first_tiers:
			var ball_tier = first_tier + ((tier - 1) * 3)
			var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
			enabled.append(balls.size() > 0)
		chaos_button.disabled = !enabled.all(check_enabled)

func check_lifesteal_enabled():
	var first_tiers = [1, 3]
	var tiers = [BallsManager.tier]
	for tier in tiers:
		lifesteal_button.text = "Lifesteal %s" % [tier]
		var enabled: Array = []
		for first_tier in first_tiers:
			var ball_tier = first_tier + ((tier - 1) * 3)
			var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
			enabled.append(balls.size() > 0)
		lifesteal_button.disabled = !enabled.all(check_enabled)

func check_enabled(enabled):
	return enabled

func check_attack_enabled():
	if actions_left <= 0 || !my_turn:
		attack_button.disabled = true
		return
	var first_tier = 1
	var tiers = [action_tiers.attack]
	for tier in tiers:
		var amount: int = ATTACK_AMOUNT
		var ball_tier = first_tier + ((tier - 1) * 3)
		if (BallsManager.scale_with_tier):
			amount *= tier
		attack_button.text = "Attack %s (%s)" % [tier, amount]
		var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
		attack_button.disabled = !balls.size() > 0

func check_defense_enabled():
	if actions_left <= 0 || !my_turn:
		shield_button.disabled = true
		return
	var first_tier = 2
	var tiers = [action_tiers.shield]
	for tier in tiers:
		var amount: int = SHIELD_AMOUNT
		var ball_tier = first_tier + ((tier - 1) * 3)
		if (BallsManager.scale_with_tier):
			amount *= tier
		shield_button.text = "Defense %s (%s)" % [tier, amount]
		var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
		shield_button.disabled = !balls.size() > 0

func check_buff_enabled():
	var first_tier = 3
	var tiers = [BallsManager.tier]
	for tier in tiers:
		var amount: int = HEAL_AMOUNT
		var ball_tier = first_tier + ((tier - 1) * 3)
		if (BallsManager.scale_with_tier):
			amount *= ball_tier
		heal_button.text = "Buff %s (%s)" % [tier, amount]
		var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
		heal_button.disabled = !balls.size() > 0

func turn_finished():
	attack_button.disabled = true
	shield_button.disabled = true
	heal_button.disabled = true
	ghost_ball_button.disabled = true
	explode_button.disabled = true
	rainbow_button.disabled = true

func turn_started():
	attack_button.disabled = false
	shield_button.disabled = false
	heal_button.disabled = false 
	ghost_ball_button.disabled = false || mana < GHOST_BALL_MANA
	explode_button.disabled = false || mana < EXPLODE_MANA
	rainbow_button.disabled = false || mana < RAINBOW_MANA

func player_damaged(damage: int) -> void:
	shield -= damage
	if shield < 0:
		damage = -1 * shield
		shield = 0
	else:
		damage = 0
	hp -= damage
	if hp <= 0:
		hp = 0
		SignalManager.on_game_over.emit()
	shield_label.text = str(shield)
	update_health_ui(hp)

func health_gained(health: int) -> void:
	hp += health
	if hp > max_hp:
		hp = max_hp
	update_health_ui(hp)

func shield_gained(amount: int) -> void:
	shield += amount
	shield_label.text = str(shield)

func update_health_ui(_new_hp: int) -> void:
	health_bar.value = hp
	health_label.text = str("%s/%s" % [hp, max_hp])

func update_mana_ui(_new_mana: int) -> void:
	attack_button.disabled = mana < ATTACK_MANA
	shield_button.disabled = mana < SHIELD_MANA
	heal_button.disabled = mana < HEAL_MANA
	ghost_ball_button.disabled = mana < GHOST_BALL_MANA
	explode_button.disabled = mana < EXPLODE_MANA
	rainbow_button.disabled = mana < RAINBOW_MANA
	mana_bar.value = mana
	mana_label.text = str("%s/100" % mana)

func ball_exploded(_first_pos: Vector2, _second_pos: Vector2, tier: int, owner: String):
	if BallsManager.turn == 1:
			return
	mana += tier * 5
	if explosion_chain:
		mana += 5
	if mana > 100:
		mana = 100
	explosion_chain = true
	chain_explosion_timer.start()
	#update_mana_ui(mana)

func _on_chain_explosion_timer_timeout():
	explosion_chain = false

#func on_chaos_press():
	#var first_tiers = [1, 2, 3]
	#var tiers = [BallsManager.tier]
	#for tier in tiers:
		#var do: bool = false
		#var all_balls = []
		#for first_tier in first_tiers:
			#var ball_tier = first_tier + ((tier - 1) * 3)
			#var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
			#if BallsManager.pick_random:
				#var ball = balls.pick_random()
				#all_balls.append(ball)
			#else:
				#all_balls.append_array(balls)
			#do = balls.size() > 0
		#if (do):
			#for ball in all_balls:
				#ball.queue_free()
			#for i in range(CHAOS_AMOUNT * tier):
				#SignalManager.spawn_random_ball.emit()
				#await get_tree().create_timer(0.7).timeout
			#return

func on_chaos_press():
	var first_tier = 3
	var tiers = [action_tiers.chaos]
	for tier in tiers:
		var amount: int = CHAOS_AMOUNT
		var ball_tier = first_tier + ((tier - 1) * 3)
		if BallsManager.scale_with_tier:
			amount *= tier
		var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
		if (balls.size() > 0):
			increase_action_tier("chaos")
			update_actions_left(actions_left - 1)
			var ball: Ball = balls.pick_random()
			var effect_scale := make_scale("chaos", ball)
			amount *= effect_scale
			#ball.queue_free()
			SignalManager.balls_left_gained.emit(amount)
			#for i in range(amount):
				#SignalManager.spawn_random_ball.emit()
				#await get_tree().create_timer(0.7).timeout
			return

func on_lifesteal_press():
	var first_tiers = [1, 3]
	var tiers = [BallsManager.tier]
	for tier in tiers:
		var att_amount: int = ATTACK_AMOUNT
		var h_amount: int = HEAL_AMOUNT
		var do: bool = false
		var all_balls = []
		var ball_tiers = []
		for first_tier in first_tiers:
			var ball_tier = first_tier + ((tier - 1) * 3)
			ball_tiers.append(ball_tier)
			var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
			if BallsManager.pick_random:
				var ball = balls.pick_random()
				all_balls.append(ball)
			else:
				all_balls.append_array(balls)
			do = balls.size() > 0
		if (do):
			if BallsManager.scale_with_tier:
				att_amount *= ball_tiers[0]
				h_amount *= ball_tiers[1]
			SignalManager.enemy_damaged.emit(att_amount)
			SignalManager.health_gained.emit(h_amount)
			for ball in all_balls:
				ball.queue_free()
			return

func on_attack_pressed():
	var first_tier = 1
	var tiers = [action_tiers.attack]
	for tier in tiers:
		var amount: int = ATTACK_AMOUNT
		var ball_tier = first_tier + ((tier - 1) * 3)
		if BallsManager.scale_with_tier:
			amount *= tier
		var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
		if (balls.size() > 0):
			increase_action_tier("attack")
			update_actions_left(actions_left - 1)
			var ball = balls.pick_random()
			var effect_scale := make_scale("attack", ball)
			amount *= effect_scale
			#ball.queue_free()
			SignalManager.enemy_damaged.emit(amount)
			return

#func on_attack_pressed():
	#if mana < ATTACK_MANA:
		#return
	#mana -= ATTACK_MANA
	##update_mana_ui(mana)
	#SignalManager.enemy_damaged.emit(ATTACK_AMOUNT)

func on_shield_pressed():
	var first_tier = 2
	var tiers = [action_tiers.shield]
	for tier in tiers:
		var amount: int = SHIELD_AMOUNT
		var ball_tier = first_tier + ((tier - 1) * 3)
		if BallsManager.scale_with_tier:
			amount *= tier
		var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
		if (balls.size() > 0):
			increase_action_tier("shield")
			update_actions_left(actions_left - 1)
			var ball = balls.pick_random()
			var effect_scale := make_scale("shield", ball)
			amount *= effect_scale
			#ball.queue_free()
			SignalManager.shield_gained.emit(amount)
			return

#func on_shield_pressed():
	#if mana < SHIELD_MANA:
		#return
	#mana -= SHIELD_MANA
	##update_mana_ui(mana)
	#SignalManager.shield_gained.emit(SHIELD_AMOUNT)

func on_health_pressed():
	var first_tier = 3
	var tiers = [BallsManager.tier]
	for tier in tiers:
		var amount: int = HEAL_AMOUNT
		var ball_tier = first_tier + ((tier - 1) * 3)
		if BallsManager.scale_with_tier:
			amount *= ball_tier
		var balls = get_tree().get_nodes_in_group("ball_%s" % ball_tier)
		if (balls.size() > 0):
			SignalManager.health_gained.emit(amount)
			if BallsManager.pick_random:
				var ball = balls.pick_random()
				ball.queue_free()
			else:
				for ball in balls:
					ball.queue_free()
			return

#func on_health_pressed():
	#if mana < HEAL_MANA:
		#return
	#mana -= HEAL_MANA
	##update_mana_ui(mana)
	#SignalManager.health_gained.emit(HEAL_AMOUNT)

func on_ghost_ball_pressed():
	if mana < GHOST_BALL_MANA:
		return
	mana -= GHOST_BALL_MANA
	#update_mana_ui(mana)
	var ghost_ball_config = Dictionary(BallsManager.BALLS[selected_ball].duplicate())
	ghost_ball_config["type"] = "ghost"
	BallsManager.set_current_ball(ghost_ball_config)

func on_explode_press():
	if mana < EXPLODE_MANA:
		return
	mana -= EXPLODE_MANA
	#update_mana_ui(mana)
	SignalManager.explode_ball_tier.emit(BallsManager.BALLS[selected_ball].tier)

func on_rainbow_press():
	if mana < RAINBOW_MANA:
		return
	mana -= RAINBOW_MANA
	#update_mana_ui(mana)
	BallsManager.set_current_ball(rainbown_config)

func _unhandled_input(event):
	if event.is_action_pressed("change_selected_ball"):
		selected_ball += 1
		if selected_ball >= BallsManager.BALLS.size():
			selected_ball = 0
		ghost_ball_sprite.texture = BallsManager.BALLS[selected_ball].sprite
		ghost_ball_icon.texture = BallsManager.BALLS[selected_ball].icon
		explode_sprite.texture = BallsManager.BALLS[selected_ball].sprite
		explode_icon.texture = BallsManager.BALLS[selected_ball].icon

func make_scale(type: String, chosen_ball: Ball) -> int:
	var tiers
	if type == 'attack':
		tiers = [1, 4, 7]
	elif type == 'shield':
		tiers = [2, 5, 8]
	else:
		tiers = [3, 6, 9]
	var total = 0
	if GameManager.character_chosen == GameManager.CHARACTER.QUANTITY:
		for tier in tiers:
			total += get_tree().get_nodes_in_group("ball_%s" % tier).size()
	if GameManager.character_chosen == GameManager.CHARACTER.FUSION:
		total = GameManager.fusions
	if GameManager.character_chosen == GameManager.CHARACTER.AREA:
		total = chosen_ball.get_nearby_balls()
	return total

func increase_action_tier(action: String) -> void:
	action_tiers[action] += 1
	if action_tiers[action] > 3:
		action_tiers[action] = 1

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


func _on_timer_timeout(): # Timer de teste de xp só
	SignalManager.gain_exp.emit(5)
	#SignalManager.gain_exp.emit(10)
	#pass
