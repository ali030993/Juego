extends FighterBase

@export var projectile_scene: PackedScene = preload("res://scenes/combat/ProjectileBase.tscn")

func _ready() -> void:
	super._ready()
	fighter_name = "Volt"
	weight = 85.0 # Ligero
	run_speed = 390.0 # Rápido
	jump_force = -540.0
	if visuals:
		visuals.body_color = Color(0.95, 0.9, 0.15)
		visuals.accent_color = Color(0.2, 0.9, 1.0)
		visuals.character_symbol = "V"

func attack_normal() -> void:
	visuals.trigger_attack_visual("kick")
	hitbox.damage = 7.0
	hitbox.base_knockback = 240.0
	hitbox.knockback_growth = 7.5
	hitbox.launch_angle = Vector2(1.0, -0.3).normalized()
	hitbox.hit_spark_color = Color(0.3, 0.9, 1.0)
	hitbox.position = Vector2(34 * facing, -20)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.15).timeout
	finish_attack()

func attack_neutral_special() -> void:
	visuals.trigger_attack_visual("cast")
	var proj = projectile_scene.instantiate() as Projectile
	proj.global_position = global_position + Vector2(facing * 35, -28)
	proj.direction = facing
	proj.attacker = self
	proj.speed = 660.0 # Proyectil de alta velocidad
	proj.damage = 8.0
	proj.base_knockback = 260.0
	proj.knockback_growth = 7.0
	proj.element_color = Color(0.3, 0.95, 1.0)
	get_parent().add_child(proj)
	
	await get_tree().create_timer(0.22).timeout
	finish_attack()

func attack_up_special() -> void:
	# Recovery: Centella relámpago diagonal
	visuals.trigger_attack_visual("dash")
	velocity = Vector2(facing * 420.0, -680.0)
	
	hitbox.damage = 11.0
	hitbox.base_knockback = 340.0
	hitbox.knockback_growth = 9.0
	hitbox.launch_angle = Vector2(0.8, -0.8).normalized()
	hitbox.hit_spark_color = Color(0.9, 1.0, 0.2)
	hitbox.position = Vector2(25 * facing, -25)
	hitbox.monitoring = true
	
	GameManager.spawn_hit_spark(global_position, Color(0.2, 0.9, 1.0), 0.7)
	await get_tree().create_timer(0.32).timeout
	finish_attack()

