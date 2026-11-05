extends Node
class_name AIController

var fighter: FighterBase
var target: FighterBase = null

var stage_center: Vector2 = Vector2(640, 360)
var stage_half_width: float = 380.0
var stage_ledge_y: float = 400.0

var decision_timer: float = 0.0
var attack_cooldown: float = 0.0

func _ready() -> void:
	fighter = get_parent() as FighterBase

func _physics_process(delta: float) -> void:
	if not fighter:
		fighter = get_parent() as FighterBase
	if not fighter or fighter.is_hitstun or fighter.stocks <= 0:
		return

	decision_timer -= delta
	attack_cooldown -= delta

	# Comprobar recuperación primero (Si está fuera del escenario)
	if handle_recovery():
		return

	# Buscar objetivo cada cierto tiempo
	if decision_timer <= 0:
		decision_timer = randf_range(0.12, 0.28)
		find_target()

	if not target or target.stocks <= 0:
		find_target()
		if not target: return

	var diff_x = target.global_position.x - fighter.global_position.x
	var diff_y = target.global_position.y - fighter.global_position.y
	var dist = abs(diff_x)

	# Movimiento hacia el objetivo
	fighter.input_dir.x = sign(diff_x)
	fighter.input_dir.y = 0.0

	# Salto para perseguir si el objetivo está arriba
	if diff_y < -70.0 and fighter.is_on_floor() and randf() > 0.4:
		fighter.input_jump = true

	# Bajar de plataforma si el objetivo está abajo
	if diff_y > 80.0 and fighter.is_on_floor() and randf() > 0.5:
		fighter.input_dir.y = 1.0
		fighter.input_jump = true

	# Combate cuerpo a cuerpo
	if dist < 65.0 and attack_cooldown <= 0:
		attack_cooldown = randf_range(0.35, 0.65)
		if randf() > 0.3:
			fighter.input_attack = true
		else:
			fighter.input_special = true
	# Combate a distancia (lanzar proyectil especial)
	elif dist > 140.0 and dist < 360.0 and attack_cooldown <= 0 and randf() > 0.65:
		attack_cooldown = randf_range(0.8, 1.4)
		fighter.input_special = true

func handle_recovery() -> bool:
	var dist_from_center_x = fighter.global_position.x - stage_center.x
	var is_off_stage_x = abs(dist_from_center_x) > stage_half_width
	var is_off_stage_y = fighter.global_position.y > stage_ledge_y

	if is_off_stage_x or is_off_stage_y:
		# Moverse hacia el centro del escenario
		fighter.input_dir.x = -sign(dist_from_center_x)
		
		# Si está cayendo y tiene saltos, saltar
		if fighter.velocity.y > 50.0 and fighter.jumps_left > 0:
			fighter.input_jump = true
			return true

		# Si está muy bajo o sin saltos, usar Up-Special (Recovery)
		if fighter.global_position.y > stage_ledge_y + 40.0:
			fighter.input_dir.y = -1.0
			fighter.input_special = true
			return true
			
		return true

	return false

func find_target() -> void:
	var fighters = get_tree().get_nodes_in_group("fighters")
	var closest_dist = INF
	target = null
	for f in fighters:
		if f != fighter and f is FighterBase and f.stocks > 0:
			var d = fighter.global_position.distance_to(f.global_position)
			if d < closest_dist:
				closest_dist = d
				target = f
