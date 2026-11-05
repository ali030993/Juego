extends Node2D
class_name StageManager

@onready var camera: DynamicCamera = $Camera2D
@onready var battle_ui: BattleUI = $BattleUI
@onready var spawn_p1: Marker2D = $SpawnPoints/P1
@onready var spawn_p2: Marker2D = $SpawnPoints/P2
@onready var spawn_p3: Marker2D = $SpawnPoints/P3
@onready var spawn_p4: Marker2D = $SpawnPoints/P4
@onready var respawn_point: Marker2D = $RespawnPoint

var fighters: Array[FighterBase] = []
var active_count: int = 4

func _ready() -> void:
	# Conectar las 4 zonas de eliminación
	for zone in $BlastZones.get_children():
		if zone is Area2D:
			zone.body_entered.connect(_on_blast_zone_body_entered)
			
	call_deferred("initialize_battle")

func initialize_battle() -> void:
	var player_char_idx = GameManager.selected_fighter_idx
	
	# Elegir 3 rivales aleatorios distintos entre sí y distintos al jugador
	var roster_indices = [0, 1, 2, 3, 4, 5]
	roster_indices.erase(player_char_idx)
	roster_indices.shuffle()
	var bot_indices = roster_indices.slice(0, 3)

	var spawn_markers = [spawn_p1, spawn_p2, spawn_p3, spawn_p4]

	# 1. Instanciar Jugador 1
	var p1 = create_fighter(player_char_idx, 0, true, spawn_markers[0].global_position)
	fighters.append(p1)

	# 2. Instanciar 3 Bots IA
	for i in range(3):
		var bot_char_idx = bot_indices[i]
		var bot = create_fighter(bot_char_idx, i + 1, false, spawn_markers[i + 1].global_position)
		fighters.append(bot)

	active_count = 4
	battle_ui.setup_hud(fighters)

func create_fighter(roster_idx: int, p_idx: int, is_human: bool, spawn_pos: Vector2) -> FighterBase:
	var data = GameManager.ROSTER[roster_idx]
	var scene = load(data["scene"]) as PackedScene
	var fighter = scene.instantiate() as FighterBase
	
	fighter.global_position = spawn_pos
	fighter.add_to_group("fighters")
	add_child(fighter)
	
	# Configurar identidad
	fighter.configure_identity(p_idx, is_human)
	
	# Asignar controlador de forma limpia
	var existing_ctrl = fighter.get_node_or_null("Controller")
	if existing_ctrl:
		existing_ctrl.queue_free()
		fighter.remove_child(existing_ctrl)
		
	var ctrl: Node
	if is_human:
		ctrl = PlayerController.new()
	else:
		ctrl = AIController.new()
	ctrl.name = "Controller"
	fighter.add_child(ctrl)
	
	return fighter

func _on_blast_zone_body_entered(body: Node2D) -> void:
	if body is FighterBase:
		handle_ring_out(body)

func handle_ring_out(fighter: FighterBase) -> void:
	# Explosión en el punto donde cruzó el límite
	var ring_out_color = fighter.visuals.accent_color if fighter.visuals else Color.RED
	GameManager.spawn_ring_out(fighter.global_position, ring_out_color)
	
	fighter.lose_stock()
	
	if fighter.stocks > 0:
		# Respawn con invencibilidad
		var respawn_pos = respawn_point.global_position if respawn_point else Vector2(640, 160)
		# Variación lateral leve para que no colisionen exactamente en el mismo pixel
		respawn_pos.x += randf_range(-40, 40)
		fighter.respawn(respawn_pos)
	else:
		# Eliminado
		fighter.set_physics_process(false)
		fighter.set_process(false)
		fighter.visible = false
		fighter.global_position = Vector2(9999, 9999) # Fuera de pantalla
		active_count -= 1
		check_match_end()

func check_match_end() -> void:
	var alive: Array[FighterBase] = []
	for f in fighters:
		if f.stocks > 0:
			alive.append(f)
			
	if alive.size() <= 1:
		var winner = alive[0] if alive.size() == 1 else null
		if winner:
			battle_ui.show_victory(winner.fighter_name, winner.is_human)
		else:
			battle_ui.show_victory("EMPATE", false)

