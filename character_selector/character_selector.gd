extends TextureButton

@export var character := GameManager.CHARACTER.QUANTITY

var _level_scene: PackedScene = load("res://battle/battle.tscn")

func _on_pressed():
	GameManager.character_chosen = character
	get_tree().change_scene_to_packed(_level_scene)
