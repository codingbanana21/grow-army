extends Node

const SAVE_PATH = "user://Save.tres"
var save_data: SaveDataResource = SaveDataResource.new()

enum {CASTLE, SUPER_KNIGHT, FRIENDLY_GIANT, SAMURAI, WIZARD, PIRATE, GOLD_MULT, DAMAGE_MULT, HP_MULT, PRESTIGE}
const GAME_VERSION: float = 1.7

var save_version: float
var gold: int = 0
var wave: int = 1
var player_levels: Dictionary = {CASTLE:1, SUPER_KNIGHT:0, FRIENDLY_GIANT:0, SAMURAI:0, WIZARD:0, PIRATE:0, GOLD_MULT:0, DAMAGE_MULT:0, HP_MULT:0, PRESTIGE:0}
var enemys_to_spawn: int = 0
var enemys: int
var in_wave: bool = false
var gold_mult: float
var hp_mult: float
var damage_mult: float

func _ready() -> void:
	#save_game(true)
	load_game()
	#wave = 50


func _process(delta: float) -> void:
	gold_mult = 1.05 ** (player_levels[GOLD_MULT] + (Globals.wave / 2.0))
	hp_mult = 1.05 ** (player_levels[HP_MULT])
	damage_mult = 1.05 ** (player_levels[DAMAGE_MULT])


func reset():
	gold = 0
	wave = 1
	player_levels = {CASTLE:1, SUPER_KNIGHT:0, FRIENDLY_GIANT:0, SAMURAI:0, WIZARD:0, PIRATE:0, GOLD_MULT:0, DAMAGE_MULT:0, HP_MULT:0, PRESTIGE:0}


func save_game(dev: bool = false):
	if save_version == GAME_VERSION or dev:
		save_data.save_version = save_version
		save_data.gold = gold
		save_data.wave = wave
		save_data.player_levels = player_levels
		ResourceSaver.save(save_data, SAVE_PATH)


func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		save_data = ResourceLoader.load(SAVE_PATH).duplicate(true)
		
		save_version = save_data.save_version
		
		if save_version:
			if save_version < GAME_VERSION:
				print("out of date save")
				save_version = GAME_VERSION
			elif save_version > GAME_VERSION:
				push_error("to new save")
				return
		else:
			push_warning("no save version")
			save_version = GAME_VERSION
		
		gold = save_data.gold
		wave = save_data.wave
		#player_levels = save_data.player_levels
		player_levels.merge(save_data.player_levels, true)
	else:
		save_game()
