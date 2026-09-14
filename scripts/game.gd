class_name Game
extends Node2D

@onready var upgrades: Control = %Upgrades
@onready var next_wave_button: Button = %NextWaveButton
@onready var gold_label: Label = %GoldLabel
@onready var wave_label: Label = %WaveLabel
@onready var spawn_timer: Timer = $SpawnTimer

enum {CASTLE, SUPER_KNIGHT, FRIENDLY_GIANT, SAMURAI, WIZARD, PIRATE, GOLD_MULT, DAMAGE_MULT, HP_MULT, PRESTIGE}
enum {TYPE, SPAWN_CHANCE, SPAWN_AMOUNT, WAVE, MAX_WAVE}

const ENEMYS: Array = [
	{TYPE:"mini_fire", SPAWN_CHANCE:0.15, SPAWN_AMOUNT:2,WAVE:31, MAX_WAVE:1000},
	{TYPE:"destroyer", SPAWN_CHANCE:0.15, SPAWN_AMOUNT:1,WAVE:16, MAX_WAVE:1000},
	{TYPE:"dart_shooter", SPAWN_CHANCE:0.3, SPAWN_AMOUNT:2,WAVE:11, MAX_WAVE:1000},
	{TYPE:"giant", SPAWN_CHANCE:0.3, SPAWN_AMOUNT:1,WAVE:3, MAX_WAVE:1000},
	{TYPE:"slime_soldier", SPAWN_CHANCE:1.0, SPAWN_AMOUNT:3,WAVE:51, MAX_WAVE:1000},
	{TYPE:"zombie", SPAWN_CHANCE:1.0, SPAWN_AMOUNT:3,WAVE:0, MAX_WAVE:50},
]


func _process(delta: float) -> void:
	gold_label.text = "Gold " + str(Globals.gold)
	wave_label.text = "Wave " + str(Globals.wave)
	
	if Input.is_action_pressed("fast_speed"):
		Engine.time_scale = 3.0
	else:
		Engine.time_scale = 1.0
	
	if Input.is_action_pressed("next_wave") and Globals.in_wave == false:
		reset_wave(0)
		start_wave()
	
	if Input.is_action_pressed("save") and Globals.in_wave == false:
		Globals.save_game()
	
	if Input.is_action_pressed("reset") and Globals.in_wave == false:
		Globals.reset()
	
	if Globals.enemys <= 0 and Globals.enemys_to_spawn <= 0 and Globals.in_wave == true:
		reset_wave(1)


func _on_spawn_timer_timeout() -> void:
	Globals.enemys_to_spawn -= 1
	
	if Globals.enemys_to_spawn > 0:
		if Globals.wave > 10:
			spawn_timer.start(1.0 / (Globals.wave * 0.1))
		else:
			spawn_timer.start(1.0)
	
	var spawn_position = Vector2(128, randf_range(16, 48))
	
	if Globals.wave % 10:
		for i in range(len(ENEMYS)):
			#if enemy does not spawn go to next
			if randf() > ENEMYS[i][SPAWN_CHANCE] or Globals.wave < ENEMYS[i][WAVE] or Globals.wave > ENEMYS[i][MAX_WAVE]:
				continue
			
			for k in range(ENEMYS[i][SPAWN_AMOUNT]):
				spawn("res://enemys/"+ENEMYS[i][TYPE]+".tscn", spawn_position, 1.05, Globals.wave)
				spawn_position = Vector2(128, randf_range(16, 48))
			return
	else:
		if Globals.wave == 10:
			spawn("res://enemys/zombie_boss.tscn", spawn_position, 1.05, Globals.wave)
		elif Globals.wave == 20:
			spawn("res://enemys/giant_boss.tscn", spawn_position, 1.05, Globals.wave)
		elif Globals.wave == 30:
			spawn("res://enemys/dart_shooter_boss.tscn", spawn_position, 1.05, Globals.wave)
		elif Globals.wave == 40:
			spawn("res://enemys/boss_destroyer.tscn", spawn_position, 1.05, Globals.wave)
		elif Globals.wave > 0:
			spawn("res://enemys/evil_wizard_boss.tscn", spawn_position, 1.05, Globals.wave)


func reset_wave(add_wave: int):
	upgrades.show()
	next_wave_button.show()
	Globals.in_wave = false
	Globals.wave += add_wave
	
	for child: Node in get_children():
		if child.is_class("CharacterBody2D") or child.is_class("GPUParticles2D"):
			child.queue_free()


func start_wave():
	upgrades.hide()
	next_wave_button.hide()
	spawn_timer.start(0.1)
	Globals.in_wave = true
	
	Globals.enemys = 0
	if Globals.wave % 10:
		Globals.enemys_to_spawn = int(Globals.wave / 2.0) + 1
	else:
		Globals.enemys_to_spawn = 1
	
	if Globals.player_levels[CASTLE] > 0:
		spawn("res://troops/castle.tscn", Vector2(-64, 32), 1.05, Globals.player_levels[CASTLE])
	
	if Globals.player_levels[SUPER_KNIGHT] > 0:
		spawn("res://troops/super_knight.tscn", Vector2(32, 48), 1.05, Globals.player_levels[SUPER_KNIGHT])
		spawn("res://troops/knight.tscn", Vector2(48, 32), 1.05, Globals.player_levels[SUPER_KNIGHT])
		spawn("res://troops/knight.tscn", Vector2(48, 48), 1.05, Globals.player_levels[SUPER_KNIGHT])
		spawn("res://troops/knight.tscn", Vector2(48, 64), 1.05, Globals.player_levels[SUPER_KNIGHT])
	
	if Globals.player_levels[FRIENDLY_GIANT] > 0:
		spawn("res://troops/friendly_giant.tscn", Vector2(32, 24), 1.05, Globals.player_levels[FRIENDLY_GIANT])
	
	if Globals.player_levels[SAMURAI] > 0:
		spawn("res://troops/samurai.tscn", Vector2(0, 24), 1.05, Globals.player_levels[SAMURAI])
	
	if Globals.player_levels[WIZARD] > 0:
		spawn("res://troops/wizard.tscn", Vector2(0, 48), 1.05, Globals.player_levels[WIZARD])
	
	if Globals.player_levels[PIRATE] > 0:
		spawn("res://troops/pirate.tscn", Vector2(-32, 24), 1.05, Globals.player_levels[PIRATE])


func spawn(entity_type: NodePath, pos: Vector2, mult: float = 1.05, power: int = 0):
	var power_scale: float = float(mult ** (power - 1))
	var new_entity: Entity = load(entity_type).instantiate()
	
	new_entity.global_position = pos
	new_entity.max_hp *= power_scale
	new_entity.damage *= power_scale
	new_entity.self_healing *= power_scale
	add_child(new_entity)


func _on_next_wave_button_pressed() -> void:
	start_wave()


func _on_save_timer_timeout() -> void:
	Globals.save_game()
