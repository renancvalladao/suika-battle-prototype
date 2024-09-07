extends Node

const ICON_PATH = "res://assets/icons/"
const UPGRADES = {
	"damage_buff1":{
		"icon": ICON_PATH + "sword.png",
		"displayname": "Damage Buff",
		"details": "Increases damage dealt",
		"level": "Level 1",
		"prerequisite": [],
		"type": "buff"
	},
	"damage_buff2":{
		"icon": ICON_PATH + "sword.png",
		"displayname": "Damage Buff",
		"details": "Increases damage dealt",
		"level": "Level 2",
		"prerequisite": ["damage_buff1"],
		"type": "buff"
	},
	"damage_buff3":{
		"icon": ICON_PATH + "sword.png",
		"displayname": "Damage Buff",
		"details": "Increases damage dealt",
		"level": "Level 3",
		"prerequisite": ["damage_buff2"],
		"type": "buff"
	},
	"damage_buff4":{
		"icon": ICON_PATH + "sword.png",
		"displayname": "Damage Buff",
		"details": "Increases damage dealt",
		"level": "Level 4",
		"prerequisite": ["damage_buff3"],
		"type": "buff"
	},
	"damage_buff5":{
		"icon": ICON_PATH + "sword.png",
		"displayname": "Damage Buff",
		"details": "Increases damage dealt",
		"level": "Level 5",
		"prerequisite": ["damage_buff4"],
		"type": "buff"
	},
	"exp_bonus1":{
		"icon": ICON_PATH + "dollar.png",
		"displayname": "Exp Bonus",
		"details": "Increases exp gained when defeating enemies",
		"level": "Level 1",
		"prerequisite": [],
		"type": "buff"
	},
	"exp_bonus2":{
		"icon": ICON_PATH + "dollar.png",
		"displayname": "Exp Bonus",
		"details": "Increases exp gained when defeating enemies",
		"level": "Level 2",
		"prerequisite": ["exp_bonus1"],
		"type": "buff"
	},
	"exp_bonus3":{
		"icon": ICON_PATH + "dollar.png",
		"displayname": "Exp Bonus",
		"details": "Increases exp gained when defeating enemies",
		"level": "Level 3",
		"prerequisite": ["exp_bonus2"],
		"type": "buff"
	},
	"exp_bonus4":{
		"icon": ICON_PATH + "dollar.png",
		"displayname": "Exp Bonus",
		"details": "Increases exp gained when defeating enemies",
		"level": "Level 4",
		"prerequisite": ["exp_bonus3"],
		"type": "buff"
	},
	"exp_bonus5":{
		"icon": ICON_PATH + "dollar.png",
		"displayname": "Exp Bonus",
		"details": "Increases exp gained when killing enemies",
		"level": "Level 5",
		"prerequisite": ["exp_bonus4"],
		"type": "buff"
	},
	"slow_enemy_evolution1":{
		"icon": ICON_PATH + "card_flipdouble.png",
		"displayname": "Slow Enemy Evolution",
		"details": "Reduces enemies' evolution progress when they take damage.",
		"level": "Level 1",
		"prerequisite": [],
		"type": "buff"
	},
	"slow_enemy_evolution2":{
		"icon": ICON_PATH + "card_flipdouble.png",
		"displayname": "Slow Enemy Evolution",
		"details": "Reduces enemies' evolution progress when they take damage.",
		"level": "Level 2",
		"prerequisite": ["slow_enemy_evolution1"],
		"type": "buff"
	},
	"slow_enemy_evolution3":{
		"icon": ICON_PATH + "card_flipdouble.png",
		"displayname": "Slow Enemy Evolution",
		"details": "Reduces enemies' evolution progress when they take damage.",
		"level": "Level 3",
		"prerequisite": ["slow_enemy_evolution2"],
		"type": "buff"
	},
	"slow_enemy_evolution4":{
		"icon": ICON_PATH + "card_flipdouble.png",
		"displayname": "Slow Enemy Evolution",
		"details": "Reduces enemies' evolution progress when they take damage.",
		"level": "Level 4",
		"prerequisite": ["slow_enemy_evolution3"],
		"type": "buff"
	},
	"slow_enemy_evolution5":{
		"icon": ICON_PATH + "card_flipdouble.png",
		"displayname": "Slow Enemy Evolution",
		"details": "Reduces enemies' evolution progress when they take damage.",
		"level": "Level 5",
		"prerequisite": ["slow_enemy_evolution4"],
		"type": "buff"
	},
	"ghost_ball1":{
		"icon": ICON_PATH + "skull.png",
		"displayname": "Ghost Ball.",
		"details": "Ghost balls now have a chance to spawn.",
		"level": "Level 1",
		"prerequisite": [],
		"type": "ball"
	},
	"ghost_ball2":{
		"icon": ICON_PATH + "skull.png",
		"displayname": "Ghost Ball.",
		"details": "Increases chance to spawn a ghost ball.",
		"level": "Level 2",
		"prerequisite": ["ghost_ball1"],
		"type": "ball"
	},
	"ghost_ball3":{
		"icon": ICON_PATH + "skull.png",
		"displayname": "Ghost Ball.",
		"details": "Increases chance to spawn a ghost ball.",
		"level": "Level 3",
		"prerequisite": ["ghost_ball2"],
		"type": "ball"
	},
	"ghost_ball4":{
		"icon": ICON_PATH + "skull.png",
		"displayname": "Ghost Ball.",
		"details": "Increases chance to spawn a ghost ball.",
		"level": "Level 4",
		"prerequisite": ["ghost_ball3"],
		"type": "ball"
	},
	"ghost_ball5":{
		"icon": ICON_PATH + "skull.png",
		"displayname": "Ghost Ball.",
		"details": "Increases chance to spawn a ghost ball.",
		"level": "Level 5",
		"prerequisite": ["ghost_ball4"],
		"type": "ball"
	},
	"rainbow_ball1":{
		"icon": ICON_PATH + "crown.png",
		"displayname": "Rainbow Ball.",
		"details": "Rainbow balls now have a chance to spawn.",
		"level": "Level 1",
		"prerequisite": [],
		"type": "ball"
	},
	"rainbow_ball2":{
		"icon": ICON_PATH + "crown.png",
		"displayname": "Rainbow Ball.",
		"details": "Increases chance to spawn a rainbow ball.",
		"level": "Level 2",
		"prerequisite": ["rainbow_ball1"],
		"type": "ball"
	},
	"rainbow_ball3":{
		"icon": ICON_PATH + "crown.png",
		"displayname": "Rainbow Ball.",
		"details": "Increases chance to spawn a rainbow ball.",
		"level": "Level 3",
		"prerequisite": ["rainbow_ball2"],
		"type": "ball"
	},
	"rainbow_ball4":{
		"icon": ICON_PATH + "crown.png",
		"displayname": "Rainbow Ball.",
		"details": "Increases chance to spawn a rainbow ball.",
		"level": "Level 4",
		"prerequisite": ["rainbow_ball3"],
		"type": "ball"
	},
	"rainbow_ball5":{
		"icon": ICON_PATH + "crown.png",
		"displayname": "Rainbow Ball.",
		"details": "Increases chance to spawn a rainbow ball.",
		"level": "Level 5",
		"prerequisite": ["rainbow_ball4"],
		"type": "ball"
	},
	"bow":{
		"icon": ICON_PATH + "bow.png",
		"displayname": "Bow",
		"details": "Deals 50 damage to all enemies on pickup",
		"level": "Level 1",
		"prerequisite": [],
		"type": "item"
	}
}
