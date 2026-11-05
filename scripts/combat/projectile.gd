extends Area2D
class_name Projectile

@export var speed: float = 480.0
@export var damage: float = 9.0
@export var base_knockback: float = 260.0
@export var knockback_growth: float = 7.5
@export var launch_angle: Vector2 = Vector2(1.0, -0.5).normalized()
@export var gravity_amount: float = 0.0
@export var lifetime: float = 2.0
@export var element_color: Color = Color(1.0, 0.5, 0.1)
@export var projectile_radius: float = 12.0

var direction: float = 1.0
var attacker: CharacterBody2D = null
var current_velocity: Vector2 = Vector2.ZERO

@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Capa 32 (Proyectil), Máscara 8 (Hurtbox) + 1 (Terreno)
	collision_layer = 32
	collision_mask = 8 | 1
	current_velocity = Vector2(direction * speed, 0.0)
	
	if particles:
		particles.color = element_color
		particles.emitting = true
		
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	await get_tree().create_timer(lifetime).timeout
	destroy()

func _physics_process(delta: float) -> void:
	if gravity_amount > 0:
		current_velocity.y += gravity_amount * delta
	global_position += current_velocity * delta

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# Núcleo brillante
	draw_circle(Vector2.ZERO, projectile_radius, element_color)
	draw_circle(Vector2.ZERO, projectile_radius * 0.55, Color(1, 1, 1, 0.9))
	# Aura exterior
	draw_circle(Vector2.ZERO, projectile_radius * 1.3, Color(element_color.r, element_color.g, element_color.b, 0.35))

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox and area.character != attacker:
		var target = area.character
		if target and target.has_method("take_hit_from_source"):
			var kb_dir = launch_angle
			kb_dir.x *= direction
			target.take_hit_from_source(damage, base_knockback, knockback_growth, kb_dir.normalized(), attacker, element_color)
		destroy()

func _on_body_entered(body: Node2D) -> void:
	# Choca con el escenario
	if body != attacker and not (body is CharacterBody2D):
		destroy()

func destroy() -> void:
	GameManager.spawn_hit_spark(global_position, element_color, 0.8)
	queue_free()

