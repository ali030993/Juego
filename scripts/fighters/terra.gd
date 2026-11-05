extends FighterBase

@export var projectile_scene: PackedScene = preload("res://scenes/combat/ProjectileBase.tscn")

func _ready() -> void:
	super._ready()
	fighter_name = "Terra"
	weight = 150.0 # Tanque muy pesado
	run_speed = 280.0 # Más lento
	jump_force = -490.0
	if visuals:
		visuals.body_color = Color(0.55, 0.42, 0.3)
		visuals.accent_color = Color(0.4, 0.85, 0.35)
		visuals.character_symbol = "T"

func attack_normal() -> void:
	visuals.trigger_attack_visual("smash")
	hitbox.damage = 16.0 # Gran daño
	hitbox.base_knockback = 360.0
	hitbox.knockback_growth = 12.0
	hitbox.launch_angle = Vector2(0.9, -0.6).normalized()
	hitbox.hit_spark_color = Color(0.5, 0.8, 0.3)
	hitbox.position = Vector2(38 * facing, -25)
	hitbox.monitoring = true
	
	# Retardo para darle sensación de golpe pesado
	await get_tree().create_timer(0.3).timeout
	finish_attack()

func attack_neutral_special() -> void:
	visuals.trigger_attack_visual("toss")
	var proj = projectile_scene.instantiate() as Projectile
	proj.global_position = global_position + Vector2(facing * 35, -30)
	proj.direction = facing
	proj.attacker = self
	proj.speed = 360.0
	proj.gravity_amount = 750.0 # Lanza en parábola con caída
	proj.damage = 13.0
	proj.base_knockback = 310.0
	proj.knockback_growth = 9.5
	proj.projectile_radius = 16.0
	proj.element_color = Color(0.65, 0.5, 0.35)
	get_parent().add_child(proj)
	
	await get_tree().create_timer(0.35).timeout
	finish_attack()

func attack_up_special() -> void:
	# Recovery: Impulso sísmico hacia arriba
	visuals.trigger_attack_visual("thrust")
	velocity.y = -590.0
	velocity.x = facing * 120.0
	
	hitbox.damage = 15.0
	hitbox.base_knockback = 390.0
	hitbox.knockback_growth = 11.0
	hitbox.launch_angle = Vector2(0.3, -1.0).normalized()
	hitbox.hit_spark_color = Color(0.4, 0.9, 0.4)
	hitbox.position = Vector2(10 * facing, -30)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.45).timeout
	finish_attack()

