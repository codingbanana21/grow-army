class_name Entity
extends CharacterBody2D

@onready var entity: Sprite2D = $Entity
@onready var animation_player: AnimationPlayer = $Entity/AnimationPlayer
@onready var hit_box: Area2D = $HitBox
@onready var hp_bar: TextureProgressBar = $HpBar
@onready var hp_text: Label = $HpText
@onready var hit_text: Label = $HitText
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var attack_timer: Timer = $AttackTimer

@onready var hp: float = max_hp

enum {CASTLE, SUPER_KNIGHT, FRIENDLY_GIANT, SAMURAI, WIZARD, PIRATE, GOLD_MULT, DAMAGE_MULT, HP_MULT, PRESTIGE}

var target: Entity
var target_group: String

@export var group_number: int = 0
@export var max_hp: float = 200.0
@export var damage: float = 25.0
@export var speed: float = 300.0
@export var attack_speed: float = 1.0
@export var attck_range: float = 16.0
@export var attack_area: int = 1
@export var knockback: int = 8
@export var self_healing: float = 0.0
@export var gold: int = 6
@export var one_shot: bool = false
@export var castle: bool = false


func _ready() -> void:
	top_level = true
	
	if group_number == 0:
		add_to_group("BadEntity")
		target_group = "GoodEntity"
		hit_box.set_collision_mask_value(2, true)
		set_collision_layer_value(3, true)
		hp_bar.modulate = Color(1.0, 0.0, 0.0, 1.0)
		
		Globals.enemys += 1
	else:
		add_to_group("GoodEntity")
		target_group = "BadEntity"
		hit_box.set_collision_mask_value(3, true)
		set_collision_layer_value(2, true)
		hp_bar.modulate = Color(0.0, 1.0, 0.0, 1.0)
		
		max_hp *= Globals.hp_mult
		hp *= Globals.hp_mult
		damage *= Globals.damage_mult


func _process(delta: float) -> void:
	if hp < max_hp:
		hp += self_healing * delta * Globals.hp_mult
	
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_text.text = str(int(hp))


func _physics_process(delta: float) -> void:
	get_target()
	
	if target:
		# attack and move
		if target.global_position.distance_to(global_position) < attck_range and attack_timer.is_stopped():
			attack()
		elif target.global_position.distance_to(global_position) > attck_range and speed > 0:
			velocity += (navigation_agent_2d.get_next_path_position() - global_position).normalized() * speed * delta
			navigation_agent_2d.set_target_position(target.global_position)
	
	if speed > 0 and target:
		entity.rotation = sin(Engine.get_physics_frames() * 0.15) * 0.1
		entity.position.y = sin(Engine.get_physics_frames() * 0.3)
		entity.scale = Vector2.ONE
		
		if global_position > target.global_position:
			entity.flip_h = true
		else:
			entity.flip_h = false
	
	move_and_slide()
	velocity *= 0.85


func get_target():
	var dis: float = INF
	
	for t: Entity in get_tree().get_nodes_in_group(target_group):
		if t.global_position.distance_to(global_position) < dis:
			dis = t.global_position.distance_to(global_position)
			target = t


func attack():
	if one_shot:
		get_hit(max_hp)
	else:
		attack_timer.start(attack_speed)
	
	for t: Entity in get_tree().get_nodes_in_group(target_group):
		if t.global_position.distance_to(target.global_position) < attack_area:
			t.get_hit(damage)
			if !t.castle:
				t.velocity += (navigation_agent_2d.get_next_path_position() - global_position).normalized() * knockback


func get_hit(hit_damage):
	hp -= hit_damage
	
	# add hit effect
	animation_player.play("hit")
	hit_text.text = str(int(hit_damage))
	
	if hp <= 0:
		var new_particl: GPUParticles2D = load("res://scenes/hit.tscn").instantiate()
		new_particl.global_position = global_position
		new_particl.emitting = true
		new_particl.amount = clamp(hit_damage / max_hp * 20.0, 10, 200)
		get_parent().add_child(new_particl)
		
		if group_number == 0:
			Globals.gold += int(gold * Globals.gold_mult)
			Globals.enemys -= 1
		elif castle:
			get_parent().reset_wave(-2)
		
		queue_free()
