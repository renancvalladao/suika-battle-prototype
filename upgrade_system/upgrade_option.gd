extends TextureButton

@onready var label_name = $Name
@onready var description = $Description
@onready var level = $Level
@onready var icon = $ColorRect/UpgradeIcon
#var mouse_over = false
var upgrade = null
#@onready var player = get_tree().get_first_node_group("player")
#signal selected_upgrade(upgrade)

func _ready():
	if upgrade == null:
		upgrade = "bow"
	label_name.text = UpgradeDb.UPGRADES[upgrade]["displayname"]
	description.text = UpgradeDb.UPGRADES[upgrade]["details"]
	level.text = UpgradeDb.UPGRADES[upgrade]["level"]
	icon.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])

func _on_button_up():
	SignalManager.selected_upgrade.emit(upgrade)
