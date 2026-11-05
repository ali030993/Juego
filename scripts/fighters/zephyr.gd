extends FighterBase

@export var projectile_scene: PackedScene = preload("res://scenes/combat/ProjectileBase.tscn")

func _ready() -> void:
	super._ready()
	fighter_name = "Zephyr"
	weight = 90.0
	run_speed = 360.0
	jump_force = -560.0 # Gran salto
	double_jump_force = -500.0
	if visuals:
		visuals.body_color = Color(0.28, 0.85, 0.72)
		visuals.accent_color = Color(0.9, 1.0, 1.0)
		visuals.character_symbol = "Z"

func attack_normal() -> void:
	visuals.trigger_attack_visual("slash")
	hitbox.damage = 8.5
	hitbox.base_knockback = 260.0
	hitbox.knockback_growth = 8.0
	hitbox.launch_angle = Vector2(0.9, -0.6).normalized()
	hitbox.hit_spark_color = Color(0.4, 1.0, 0.9)
	hitbox.position = Vector2(36 * facing, -25)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.18).timeout
	finish_attack()

func attack_neutral_special() -> void:
	# Proyectil de viento que eleva verticalmente
	visuals.trigger_attack_visual("tornado")
	var proj = projectile_scene.instantiate() as Projectile
	proj.global_position = global_position + Vector2(facing * 35, -25)
	proj.direction = facing
	proj.attacker = self
	proj.speed = 420.0
	proj.damage = 9.0
	proj.base_knockback = 300.0
	proj.knockback_growth = 9.0
	proj.launch_angle = Vector2(0.2, -1.0).normalized() # Lanza hacia arriba
	proj.element_color = Color(0.5, 0.95, 0.85)
	get_parent().add_child(proj)
	
	await get_tree().create_timer(0.28).timeout
	finish_attack()

func attack_up_special() -> void:
	# Recovery: Torbellino ascendente
	visuals.trigger_attack_visual("spin")
	velocity.y = -670.0
	velocity.x = facing * 220.0
	
	hitbox.damage = 12.0
	hitbox.base_knockback = 350.0
	hitbox.knockback_growth = 9.5
	hitbox.launch_angle = Vector2(0.5, -0.9).normalized()
	hitbox.hit_spark_color = Color(0.7, 1.0, 1.0)
	hitbox.position = Vector2(15 * facing, -30)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.4).timeout
	finish_attack()

