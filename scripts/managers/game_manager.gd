class_name GameManager
extends RefCounted

# Datos globales de los 6 personajes
const ROSTER = [
	{
		"id": "pyro",
		"name": "Pyro",
		"title": "Puño de Fuego",
		"color": Color(0.95, 0.35, 0.15, 1.0),
		"accent": Color(1.0, 0.75, 0.2, 1.0),
		"description": "Luchador equilibrado con combos ardientes y bola de fuego a distancia.",
		"scene": "res://scenes/fighters/Pyro.tscn"
	},
	{
		"id": "volt",
		"name": "Volt",
		"title": "Centella Veloz",
		"color": Color(0.95, 0.9, 0.15, 1.0),
		"accent": Color(0.2, 0.9, 1.0, 1.0),
		"description": "El más rápido del plantel. Ráfagas eléctricas y teletransporte relámpago.",
		"scene": "res://scenes/fighters/Volt.tscn"
	},
	{
		"id": "terra",
		"name": "Terra",
		"title": "Coloso de Piedra",
		"color": Color(0.6, 0.45, 0.3, 1.0),
		"accent": Color(0.4, 0.8, 0.3, 1.0),
		"description": "Tanque pesado. Gran masa y resistencia, golpes devastadores y lanzamiento de rocas.",
		"scene": "res://scenes/fighters/Terra.tscn"
	},
	{
		"id": "zephyr",
		"name": "Zephyr",
		"title": "Espada de Viento",
		"color": Color(0.3, 0.85, 0.75, 1.0),
		"accent": Color(0.9, 1.0, 1.0, 1.0),
		"description": "Espadachín ágil. Gran control aéreo, tornados envolventes y recuperación en espiral.",
		"scene": "res://scenes/fighters/Zephyr.tscn"
	},
	{
		"id": "aqua",
		"name": "Aqua",
		"title": "Ninja de Marea",
		"color": Color(0.2, 0.55, 0.95, 1.0),
		"accent": Color(0.6, 0.9, 1.0, 1.0),
		"description": "Combate fluido. Trampas de burbujas flotantes y potentes géiseres propulsores.",
		"scene": "res://scenes/fighters/Aqua.tscn"
	},
	{
		"id": "umbra",
		"name": "Umbra",
		"title": "Sombra del Vacío",
		"color": Color(0.5, 0.2, 0.7, 1.0),
		"accent": Color(0.85, 0.35, 0.95, 1.0),
		"description": "Luchador místico. Esferas oscuras de vacío y teletransporte dimensional sorpresivo.",
		"scene": "res://scenes/fighters/Umbra.tscn"
	}
]

static var selected_fighter_idx: int = 0
static var main_camera: Camera2D = null

static var hit_spark_scene: PackedScene = preload("res://scenes/vfx/HitSpark.tscn")
static var ring_out_scene: PackedScene = preload("res://scenes/vfx/RingOutExplosion.tscn")

# Efecto Hitstop (congelación momentánea de impacto)
static func trigger_hitstop(duration: float = 0.06) -> void:
	Engine.time_scale = 0.05
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		await tree.create_timer(duration * 0.05, true, false, true).timeout
	Engine.time_scale = 1.0

# Sacudida de cámara
static func trigger_camera_shake(intensity: float) -> void:
	if main_camera and is_instance_valid(main_camera) and main_camera.has_method("shake"):
		main_camera.shake(intensity)

# Instanciación de efectos especiales
static func spawn_hit_spark(pos: Vector2, color: Color, power: float = 1.0) -> void:
	if not hit_spark_scene:
		return
	var spark = hit_spark_scene.instantiate()
	spark.global_position = pos
	if spark.has_method("configure"):
		spark.configure(color, power)
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene:
		tree.current_scene.add_child(spark)

static func spawn_ring_out(pos: Vector2, color: Color) -> void:
	if not ring_out_scene:
		return
	var vfx = ring_out_scene.instantiate()
	vfx.global_position = pos
	if vfx.has_method("configure"):
		vfx.configure(color)
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene:
		tree.current_scene.add_child(vfx)
