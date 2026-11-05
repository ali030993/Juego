extends Camera2D
class_name DynamicCamera

@export var min_zoom: float = 0.65
@export var max_zoom: float = 1.25
@export var margin: Vector2 = Vector2(250, 180)
@export var follow_speed: float = 5.0

var shake_intensity: float = 0.0

func _ready() -> void:
	GameManager.main_camera = self

func _process(delta: float) -> void:
	var fighters = get_tree().get_nodes_in_group("fighters")
	var alive_fighters: Array[Node2D] = []
	for f in fighters:
		if f is FighterBase and f.stocks > 0:
			alive_fighters.append(f)
			
	if alive_fighters.is_empty():
		return
		
	# 1. Calcular caja envolvente (Bounding box)
	var min_pos = alive_fighters[0].global_position
	var max_pos = alive_fighters[0].global_position
	
	for f in alive_fighters:
		min_pos.x = min(min_pos.x, f.global_position.x)
		min_pos.y = min(min_pos.y, f.global_position.y)
		max_pos.x = max(max_pos.x, f.global_position.x)
		max_pos.y = max(max_pos.y, f.global_position.y)
		
	var center = (min_pos + max_pos) * 0.5
	global_position = global_position.lerp(center, follow_speed * delta)
	
	# 2. Calcular Zoom
	var viewport_size = get_viewport_rect().size
	var span_x = (max_pos.x - min_pos.x) + margin.x * 2.0
	var span_y = (max_pos.y - min_pos.y) + margin.y * 2.0
	
	var zoom_x = viewport_size.x / max(span_x, 600.0)
	var zoom_y = viewport_size.y / max(span_y, 450.0)
	var target_zoom = clamp(min(zoom_x, zoom_y), min_zoom, max_zoom)
	
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), follow_speed * delta)
	
	# 3. Aplicar Shake
	if shake_intensity > 0.1:
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity
		shake_intensity = move_toward(shake_intensity, 0.0, delta * 40.0)
	else:
		offset = Vector2.ZERO

func shake(amount: float) -> void:
	shake_intensity = max(shake_intensity, amount)

