extends Node2D

func _draw() -> void:
	# Fondo degradado de estadio estelar
	var rect = Rect2(-1000, -800, 3280, 2320)
	draw_rect(rect, Color(0.06, 0.07, 0.12))
	
	# Líneas de cuadrícula de fondo
	var grid_color = Color(0.12, 0.16, 0.28, 0.4)
	for x in range(-800, 2200, 120):
		draw_line(Vector2(x, -600), Vector2(x, 1200), grid_color, 1.0)
	for y in range(-600, 1200, 120):
		draw_line(Vector2(-800, y), Vector2(2200, y), grid_color, 1.0)
		
	# Plataforma Principal - Arte de estadio
	var main_plat = Rect2(640 - 350, 480 - 30, 700, 70)
	draw_rect(main_plat, Color(0.15, 0.18, 0.26))
	# Borde superior brillante
	draw_line(Vector2(640 - 350, 480 - 30), Vector2(640 + 350, 480 - 30), Color(0.2, 0.8, 1.0), 4.0)
	# Base inferior angular
	draw_colored_polygon(PackedVector2Array([
		Vector2(640 - 350, 520), Vector2(640 + 350, 520),
		Vector2(640 + 200, 580), Vector2(640 - 200, 580)
	]), Color(0.1, 0.12, 0.18))
	
	# Plataformas Flotantes
	draw_floating_platform(Vector2(450, 370), 180, 16, Color(0.9, 0.4, 0.2))
	draw_floating_platform(Vector2(830, 370), 180, 16, Color(0.2, 0.9, 0.5))
	draw_floating_platform(Vector2(640, 260), 200, 16, Color(0.8, 0.3, 0.9))

func draw_floating_platform(pos: Vector2, w: float, h: float, glow_c: Color) -> void:
	var r = Rect2(pos.x - w/2.0, pos.y - h/2.0, w, h)
	draw_rect(r, Color(0.18, 0.2, 0.28))
	draw_line(Vector2(pos.x - w/2.0, pos.y - h/2.0), Vector2(pos.x + w/2.0, pos.y - h/2.0), glow_c, 3.0)

