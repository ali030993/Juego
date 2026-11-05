extends Area2D
class_name Hitbox

@export var damage: float = 10.0
@export var base_knockback: float = 240.0
@export var knockback_growth: float = 8.5
@export var launch_angle: Vector2 = Vector2(1.0, -0.6).normalized()
@export var hit_spark_color: Color = Color(1.0, 0.8, 0.2)
@export var hit_sound_power: float = 1.0

var attacker: CharacterBody2D = null

func _ready() -> void:
	if not attacker:
		attacker = get_owner() as CharacterBody2D
		if not attacker and get_parent() is CharacterBody2D:
			attacker = get_parent() as CharacterBody2D
	monitoring = false
	monitorable = true
	# Capa 5 (Hitbox = 16), Máscara 4 (Hurtbox = 8)
	collision_layer = 16
	collision_mask = 8

func get_knockback_vector(current_percent: float, facing_dir: float) -> Vector2:
	# Fórmula Smash Bros:
	# El knockback total escala con el porcentaje acumulado del receptor
	var force: float = base_knockback + (current_percent * knockback_growth)
	var dir: Vector2 = launch_angle
	dir.x *= facing_dir
	return dir.normalized() * force
