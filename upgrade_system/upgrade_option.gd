extends TextureButton

#var mouse_over = false
var upgrade = null
#@onready var player = get_tree().get_first_node_group("player")
#signal selected_upgrade(upgrade)


func _on_button_up():
	SignalManager.selected_upgrade.emit(upgrade)
