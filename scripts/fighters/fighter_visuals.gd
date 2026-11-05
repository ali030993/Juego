extends Node2D
class_name FighterVisuals

@export var body_color: Color = Color(0.9, 0.3, 0.2)
@export var accent_color: Color = Color(1.0, 0.8, 0.2)
@export var character_symbol: String = "P" # P, V, T, Z, A, U

var fighter: CharacterBody2D
var blink_timer: float = 0.0
var hurt_flash_timer: float = 0.0
var attack_anim_progress: float = 0.0
var is_punching: bool = false
var punch_type: String = ""

# Deformación para Squash & Stretch
var visual_scale: Vector2 = Vector2.ONE
var player_label: String = "P1"
var label_color: Color = Color.RED

func _ready() -> void:
	fighter = get_parent() as CharacterBody2D

func _process(delta: float) -> void:
	if not fighter: return
	
	# Squash & Stretch suave hacia escala normal
	visual_scale = visual_scale.lerp(Vector2.ONE, delta * 12.0)
	scale = visual_scale
	
	# Temporizador de parpadeo por invencibilidad
	if fighter.get("is_invincible"):
		blink_timer += delta * 18.0
		visible = int(blink_timer) % 2 == 0
	else:
		visible = true
		
	# Flash de dolor
	if hurt_flash_timer > 0.0:
		hurt_flash_timer -= delta
		
	# Progreso de golpe
	if attack_anim_progress > 0.0:
		attack_anim_progress -= delta * 4.0
		if attack_anim_progress <= 0:
			is_punching = false
			
	queue_redraw()

func trigger_jump_stretch() -> void:
	visual_scale = Vector2(0.75, 1.35)

func trigger_land_squash() -> void:
	visual_scale = Vector2(1.35, 0.75)

func trigger_hurt_flash() -> void:
	hurt_flash_timer = 0.2
	visual_scale = Vector2(1.2, 0.8)

func trigger_attack_visual(type: String) -> void:
	punch_type = type
	is_punching = true
	attack_anim_progress = 1.0
	visual_scale = Vector2(1.3, 0.9)

func _draw() -> void:
	var base_c = body_color
	if hurt_flash_timer > 0.0:
		base_c = Color.WHITE
		
	# 1. Aura elemental de fondo
	draw_circle(Vector2(0, -25), 28.0, Color(accent_color.r, accent_color.g, accent_color.b, 0.25))
	
	# 2. Piernas / Pies
	draw_rect(Rect2(-14, -8, 10, 10), base_c.darkened(0.3))
	draw_rect(Rect2(4, -8, 10, 10), base_c.darkened(0.3))

	# 3. Torso / Cuerpo
	draw_rect(Rect2(-16, -34, 32, 28), base_c)
	# Detalle interior
	draw_rect(Rect2(-10, -30, 20, 20), accent_color)

	# 4. Cabeza
	draw_circle(Vector2(0, -44), 16.0, base_c)
	# Cresta / Cuerno / Casco distintivo
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, -56), Vector2(0, -66), Vector2(10, -56)
	]), accent_color)

	# 5. Ojos (Miran al frente según escala)
	draw_circle(Vector2(6, -45), 3.5, Color.WHITE)
	draw_circle(Vector2(7.5, -45), 1.8, Color.BLACK)

	# 6. Efecto de Ataque / Puño extendido
	if is_punching:
		var punch_x = 24.0 + (attack_anim_progress * 18.0)
		draw_circle(Vector2(punch_x, -28), 12.0, accent_color)
		draw_arc(Vector2(punch_x, -28), 16.0, -PI/2, PI/2, 16, Color.WHITE, 3.0)

	# 7. Indicador flotante sobre la cabeza (P1, CPU1, CPU2, CPU3)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-8, -75), Vector2(8, -75), Vector2(0, -68)
	]), label_color)

