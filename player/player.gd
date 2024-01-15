extends Node2D

const ATTACK_MANA = 20
const ATTACK_AMOUNT = 10
const SHIELD_MANA = 15
const SHIELD_AMOUNT = 15
const HEAL_MANA = 20
const HEAL_AMOUNT = 20
const GHOST_BALL_MANA = 50
const EXPLODE_MANA = 50
const RAINBOW_MANA = 50

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

var hp = 100
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

func _ready():
	SignalManager.player_damaged.connect(player_damaged)
	SignalManager.health_gained.connect(health_gained)
	SignalManager.shield_gained.connect(shield_gained)
	BallsManager.ball_exploded.connect(ball_exploded)
	#BallsManager.turn_finished.connect(turn_finished)
	SignalManager.turn_started.connect(turn_started)
	attack_button.text = "%s - Attack (%s)" % [ATTACK_MANA, ATTACK_AMOUNT]
	attack_button.pressed.connect(on_attack_pressed)
	shield_button.text = "%s - Shield (%s)" % [SHIELD_MANA, SHIELD_AMOUNT]
	shield_button.pressed.connect(on_shield_pressed)
	heal_button.text = "%s - Heal (%s)" % [HEAL_MANA, HEAL_AMOUNT]
	heal_button.pressed.connect(on_health_pressed)
	ghost_ball_button.text = "%s - Ghost Ball" % GHOST_BALL_MANA
	ghost_ball_button.pressed.connect(on_ghost_ball_pressed)
	explode_button.text = "%s - Explode" % EXPLODE_MANA
	explode_button.pressed.connect(on_explode_press)
	rainbow_button.text = "%s - Rainbow" % RAINBOW_MANA
	rainbow_button.pressed.connect(on_rainbow_press)
	update_health_ui(hp)
	update_mana_ui(mana)
	shield_label.text = str(shield)
	ghost_ball_sprite.texture = BallsManager.BALLS[selected_ball].sprite
	ghost_ball_icon.texture = BallsManager.BALLS[selected_ball].icon
	explode_sprite.texture = BallsManager.BALLS[selected_ball].sprite
	explode_icon.texture = BallsManager.BALLS[selected_ball].icon
	SignalManager.mana_gained.connect(mana_gained)

func mana_gained(amount: int):
	mana += amount
	if mana > 100:
		mana = 100
	update_mana_ui(mana)

func turn_finished():
	attack_button.disabled = true
	shield_button.disabled = true
	heal_button.disabled = true
	ghost_ball_button.disabled = true
	explode_button.disabled = true
	rainbow_button.disabled = true

func turn_started():
	attack_button.disabled = false || mana < ATTACK_MANA
	shield_button.disabled = false || mana < SHIELD_MANA
	heal_button.disabled = false || mana < HEAL_MANA
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
	if hp > 100:
		hp = 100
	update_health_ui(hp)

func shield_gained(amount: int) -> void:
	shield += amount
	shield_label.text = str(shield)

func update_health_ui(new_hp: int) -> void:
	health_bar.value = hp
	health_label.text = str("%s/100" % hp)

func update_mana_ui(new_mana: int) -> void:
	attack_button.disabled = mana < ATTACK_MANA
	shield_button.disabled = mana < SHIELD_MANA
	heal_button.disabled = mana < HEAL_MANA
	ghost_ball_button.disabled = mana < GHOST_BALL_MANA
	explode_button.disabled = mana < EXPLODE_MANA
	rainbow_button.disabled = mana < RAINBOW_MANA
	mana_bar.value = mana
	mana_label.text = str("%s/100" % mana)

func ball_exploded(_first_pos: Vector2, _second_pos: Vector2, tier: int):
	if BallsManager.turn == 1:
			return
	mana += tier * 5
	if explosion_chain:
		mana += 5
	if mana > 100:
		mana = 100
	explosion_chain = true
	chain_explosion_timer.start()
	update_mana_ui(mana)

func _on_chain_explosion_timer_timeout():
	explosion_chain = false

func on_attack_pressed():
	if mana < ATTACK_MANA:
		return
	mana -= ATTACK_MANA
	update_mana_ui(mana)
	SignalManager.enemy_damaged.emit(ATTACK_AMOUNT)

func on_shield_pressed():
	if mana < SHIELD_MANA:
		return
	mana -= SHIELD_MANA
	update_mana_ui(mana)
	SignalManager.shield_gained.emit(SHIELD_AMOUNT)

func on_health_pressed():
	if mana < HEAL_MANA:
		return
	mana -= HEAL_MANA
	update_mana_ui(mana)
	SignalManager.health_gained.emit(HEAL_AMOUNT)

func on_ghost_ball_pressed():
	if mana < GHOST_BALL_MANA:
		return
	mana -= GHOST_BALL_MANA
	update_mana_ui(mana)
	var ghost_ball_config = Dictionary(BallsManager.BALLS[selected_ball].duplicate())
	ghost_ball_config["type"] = "ghost"
	BallsManager.set_current_ball(ghost_ball_config)

func on_explode_press():
	if mana < EXPLODE_MANA:
		return
	mana -= EXPLODE_MANA
	update_mana_ui(mana)
	SignalManager.explode_ball_tier.emit(BallsManager.BALLS[selected_ball].tier)

func on_rainbow_press():
	if mana < RAINBOW_MANA:
		return
	mana -= RAINBOW_MANA
	update_mana_ui(mana)
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
