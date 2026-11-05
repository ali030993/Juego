extends FighterBase

@export var projectile_scene: PackedScene = preload("res://scenes/combat/ProjectileBase.tscn")

func _ready() -> void:
	super._ready()
	fighter_name = "Umbra"
	weight = 94.0
	run_speed = 350.0
	jump_force = -530.0
	if visuals:
		visuals.body_color = Color(0.48, 0.18, 0.68)
		visuals.accent_color = Color(0.85, 0.35, 0.95)
		visuals.character_symbol = "U"

func attack_normal() -> void:
	visuals.trigger_attack_visual("scythe")
	hitbox.damage = 10.0
	hitbox.base_knockback = 280.0
	hitbox.knockback_growth = 8.5
	hitbox.launch_angle = Vector2(0.8, -0.6).normalized()
	hitbox.hit_spark_color = Color(0.8, 0.3, 0.95)
	hitbox.position = Vector2(35 * facing, -25)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.22).timeout
	finish_attack()

func attack_neutral_special() -> void:
	# Esfera oscura de vacío
	visuals.trigger_attack_visual("void_orb")
	var proj = projectile_scene.instantiate() as Projectile
	proj.global_position = global_position + Vector2(facing * 35, -28)
	proj.direction = facing
	proj.attacker = self
	proj.speed = 300.0
	proj.damage = 12.0
	proj.base_knockback = 320.0
	proj.knockback_growth = 9.5
	proj.projectile_radius = 14.0
	proj.element_color = Color(0.7, 0.2, 0.85)
	get_parent().add_child(proj)
	
	await get_tree().create_timer(0.3).timeout
	finish_attack()

func attack_up_special() -> void:
	# Recovery: Teletransporte de Sombra (Void Warp)
	visuals.trigger_attack_visual("warp")
	GameManager.spawn_hit_spark(global_position, Color(0.6, 0.2, 0.8), 0.8)
	
	# Desplazamiento instantáneo hacia arriba y adelante
	position += Vector2(facing * 120.0, -180.0)
	velocity = Vector2(facing * 150.0, -250.0)
	
	GameManager.spawn_hit_spark(global_position, Color(0.85, 0.35, 0.95), 1.0)
	
	# Daño radial alrededor al reaparecer
	hitbox.damage = 12.0
	hitbox.base_knockback = 340.0
	hitbox.knockback_growth = 9.0
	hitbox.launch_angle = Vector2(facing * 0.7, -0.7).normalized()
	hitbox.hit_spark_color = Color(0.85, 0.3, 1.0)
	hitbox.position = Vector2(0, -25)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.25).timeout
	finish_attack()

