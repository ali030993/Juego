extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D

var color: Color = Color.ORANGE
var ring_radius: float = 5.0
var ring_max_radius: float = 35.0
var ring_alpha: float = 1.0

func configure(p_color: Color, power: float = 1.0) -> void:
	color = p_color
	ring_max_radius = 25.0 + (power * 20.0)
	if particles:
		particles.color = p_color
		particles.initial_velocity_min = 120.0 * power
		particles.initial_velocity_max = 240.0 * power
		particles.restart()

func _ready() -> void:
	if particles:
		particles.emitting = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "ring_radius", ring_max_radius, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "ring_alpha", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.4).timeout
	queue_free()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if ring_alpha > 0.01:
		var c = color
		c.a = ring_alpha
		draw_circle(Vector2.ZERO, ring_radius, Color(c.r, c.g, c.b, ring_alpha * 0.3))
		draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 32, c, 3.0)
		# Chispas en cruz
		var arm_len = ring_radius * 1.4
		draw_line(Vector2(-arm_len, 0), Vector2(arm_len, 0), Color(1, 1, 1, ring_alpha), 2.0)
		draw_line(Vector2(0, -arm_len), Vector2(0, arm_len), Color(1, 1, 1, ring_alpha), 2.0)

