extends FighterBase

@export var projectile_scene: PackedScene = preload("res://scenes/combat/ProjectileBase.tscn")

func _ready() -> void:
	super._ready()
	fighter_name = "Pyro"
	weight = 100.0
	run_speed = 340.0
	jump_force = -520.0
	if visuals:
		visuals.body_color = Color(0.95, 0.32, 0.15)
		visuals.accent_color = Color(1.0, 0.75, 0.2)
		visuals.character_symbol = "P"

func attack_normal() -> void:
	visuals.trigger_attack_visual("punch")
	hitbox.damage = 9.0
	hitbox.base_knockback = 270.0
	hitbox.knockback_growth = 8.5
	hitbox.launch_angle = Vector2(1.0, -0.5).normalized()
	hitbox.hit_spark_color = Color(1.0, 0.45, 0.1)
	hitbox.position = Vector2(32 * facing, -25)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.2).timeout
	finish_attack()

func attack_neutral_special() -> void:
	visuals.trigger_attack_visual("cast")
	var proj = projectile_scene.instantiate() as Projectile
	proj.global_position = global_position + Vector2(facing * 35, -28)
	proj.direction = facing
	proj.attacker = self
	proj.speed = 460.0
	proj.damage = 10.0
	proj.base_knockback = 280.0
	proj.knockback_growth = 8.0
	proj.element_color = Color(1.0, 0.4, 0.1)
	get_parent().add_child(proj)
	
	await get_tree().create_timer(0.3).timeout
	finish_attack()

func attack_up_special() -> void:
	# Recovery: Cohete ardiente hacia arriba
	visuals.trigger_attack_visual("uppercut")
	velocity.y = -620.0
	velocity.x = facing * 180.0
	
	hitbox.damage = 14.0
	hitbox.base_knockback = 380.0
	hitbox.knockback_growth = 10.5
	hitbox.launch_angle = Vector2(0.4, -1.0).normalized()
	hitbox.hit_spark_color = Color(1.0, 0.8, 0.2)
	hitbox.position = Vector2(15 * facing, -35)
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.4).timeout
	finish_attack()

