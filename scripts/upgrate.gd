class_name Upgrade
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var info_label: Label = %InfoLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var upgrade_type: upgrades
@export var scale_cost: float = 1.05
@export var start_cost: int = 50
@export var unlock_cost: int = 100
@export var image: Texture = preload("uid://cuotywv2hkrul")
@export var update_name: String
@export var extra_text: String

enum upgrades {CASTLE, SUPER_KNIGHT, FRIENDLY_GIANT, SAMURAI, WIZARD, PIRATE, GOLD_MULT, DAMAGE_MULT, HP_MULT, PRESTIGE}

var cost: int
var show_info: bool = false


func _process(delta: float) -> void:
	sprite_2d.texture = image
	
	if show_info:
		info_label.show()
		if sprite_2d.scale.x <= 1.5:
			sprite_2d.scale *= 1.1
		info_label.global_position = get_global_mouse_position()
	else:
		if sprite_2d.scale.x >= 1.0:
			sprite_2d.scale *= 0.9
		info_label.hide()
	
	if Globals.player_levels[upgrade_type] == 0:
		info_label.text = "%s \nUnlock %d Gold \n%s"% [update_name, unlock_cost, extra_text]
		
		if Globals.gold >= unlock_cost:
			info_label.modulate = Color(1.0, 1.0, 0.0, 1.0)
		else:
			info_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		cost = int(start_cost * scale_cost ** (Globals.player_levels[upgrade_type] - 1))
		info_label.text = "%s \nUpgrade %d Gold \nLevel %d \n%s"% [update_name, cost, Globals.player_levels[upgrade_type], extra_text]
		
		if Globals.gold >= cost:
			info_label.modulate = Color(0.0, 1.0, 0.0, 1.0)
		else:
			info_label.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	show_info = true
	
	if Input.is_action_just_pressed("click"):
		if Globals.player_levels[upgrade_type] == 0:
			if Globals.gold >= unlock_cost:
				Globals.gold -= unlock_cost
				Globals.player_levels[upgrade_type] += 1
				audio_stream_player.play()
		elif Globals.gold >= cost:
			Globals.gold -= cost
			Globals.player_levels[upgrade_type] += 1
			audio_stream_player.play()


func _on_mouse_exited() -> void:
	show_info = false
