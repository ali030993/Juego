extends FighterBase

@export var projectile_scene: PackedScene = preload("res://scenes/combat/ProjectileBase.tscn")

func _ready() -> void:
	super._ready()
	fighter_name = "Aqua"
	weight = 95.0
	run_speed = 345.0
	jump_force = -510.0
	max_jumps = 3 # Triple salto de agua
	jumps_left = 3
	if visuals:
		visuals.body_color = Color(0.18, 0.52, 0.95)
		visuals.accent_color = Color(0.65, 0.9, 1.0)
		visuals.character_symbol = "A"

func attack_normal() -> void:
	visuals.trigger_attack_visual("hydro_strike")
	hitbox.damage = 8.0
	hitbox.base_knockback = 250.0
	hitbox.knockback_growth = 7.8
	hitbox.launch_angle = Vector2(1.0, -0.4).normalized()
	hitbox.hit_spark_color = Color(0.3, 0.7, 1.0)
	hitbox.position = Vector2(32 * facing, -24)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.2).timeout
	finish_attack()

func attack_neutral_special() -> void:
	visuals.trigger_attack_visual("bubble")
	var proj = projectile_scene.instantiate() as Projectile
	proj.global_position = global_position + Vector2(facing * 35, -25)
	proj.direction = facing
	proj.attacker = self
	proj.speed = 260.0 # Burbuja lenta pero molesta
	proj.damage = 11.0
	proj.base_knockback = 310.0
	proj.knockback_growth = 9.0
	proj.projectile_radius = 15.0
	proj.element_color = Color(0.35, 0.75, 1.0)
	get_parent().add_child(proj)
	
	await get_tree().create_timer(0.3).timeout
	finish_attack()

func attack_up_special() -> void:
	# Recovery: Géiser a presión propulsando verticalmente
	visuals.trigger_attack_visual("geyser")
	velocity.y = -680.0
	velocity.x = facing * 140.0
	
	hitbox.damage = 13.0
	hitbox.base_knockback = 360.0
	hitbox.knockback_growth = 10.0
	hitbox.launch_angle = Vector2(0.2, -1.0).normalized()
	hitbox.hit_spark_color = Color(0.4, 0.8, 1.0)
	hitbox.position = Vector2(10 * facing, -15)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.38).timeout
	finish_attack()

