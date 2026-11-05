extends Node2D

@onready var particles: CPUParticles2D = $CPUParticles2D

var color: Color = Color.RED
var radius: float = 10.0
var max_radius: float = 120.0
var alpha: float = 1.0

func configure(p_color: Color) -> void:
	color = p_color
	if particles:
		particles.color = p_color
		particles.restart()

func _ready() -> void:
	if particles:
		particles.emitting = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "radius", max_radius, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "alpha", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(0.6).timeout
	queue_free()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if alpha > 0.01:
		var c = color
		c.a = alpha * 0.4
		draw_circle(Vector2.ZERO, radius, c)
		draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1, 1, 1, alpha), 5.0)
		# Rayos estelares
		for i in range(8):
			var angle = (TAU / 8.0) * i
			var dir = Vector2(cos(angle), sin(angle))
			draw_line(dir * (radius * 0.4), dir * (radius * 1.5), Color(color.r, color.g, color.b, alpha), 4.0)

