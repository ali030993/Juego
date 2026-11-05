extends CharacterBody2D
class_name FighterBase

# Parámetros físicos base
@export var fighter_name: String = "Luchador"
@export var weight: float = 100.0 # Más pesado = vuela menos lejos
@export var run_speed: float = 330.0
@export var jump_force: float = -520.0
@export var double_jump_force: float = -470.0
@export var max_jumps: int = 2
@export var gravity_scale: float = 1300.0
@export var fall_speed_max: float = 800.0

# Estado Smash
var damage_percent: float = 0.0
var stocks: int = 3
var jumps_left: int = 2
var facing: float = 1.0
var is_hitstun: bool = false
var is_attacking: bool = false
var is_invincible: bool = false
var was_on_floor: bool = false

# Entradas virtuales (asignadas por PlayerController o AIController)
var input_dir: Vector2 = Vector2.ZERO
var input_jump: bool = false
var input_attack: bool = false
var input_special: bool = false

# Identificador de jugador (0: P1, 1: CPU 1, 2: CPU 2, 3: CPU 3)
var player_index: int = 0
var is_human: bool = false

# Nodos hijos
@onready var visuals: FighterVisuals = $Visuals
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitstun_timer: Timer = $HitstunTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var trail_particles: CPUParticles2D = $VFX/TrailParticles
@onready var land_particles: CPUParticles2D = $VFX/LandParticles
@onready var controller: Node = $Controller

signal damage_changed(new_percent: float)
signal stocks_changed(new_stocks: int)

func _ready() -> void:
	jumps_left = max_jumps
	if hurtbox:
		hurtbox.hit_received.connect(_on_hurtbox_hit)
		
	if hitstun_timer:
		hitstun_timer.timeout.connect(_on_hitstun_end)
		
	if invincibility_timer:
		invincibility_timer.timeout.connect(func(): is_invincible = false)

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y = min(velocity.y + (gravity_scale * delta), fall_speed_max)
	else:
		if not was_on_floor and velocity.y >= 0:
			if visuals: visuals.trigger_land_squash()
			if land_particles: land_particles.emitting = true
		jumps_left = max_jumps
		
	was_on_floor = is_on_floor()

	# 2. Si está en Hitstun (aturdido volando por los aires)
	if is_hitstun:
		velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
		if is_on_floor() and velocity.y > 0:
			# Rebote en el suelo si va muy rápido
			velocity.y = -velocity.y * 0.4
		move_and_slide()
		return

	# 3. Procesar Movimiento y Plataformas One-Way
	process_horizontal_movement(delta)
	process_vertical_movement()
	process_attacks()

	move_and_slide()

func process_horizontal_movement(delta: float) -> void:
	var move_x = input_dir.x
	if move_x != 0 and not is_attacking:
		facing = sign(move_x)
		if visuals:
			visuals.scale.x = facing
		
		if is_on_floor():
			velocity.x = move_x * run_speed
		else:
			# Control aéreo
			velocity.x = move_toward(velocity.x, move_x * run_speed, 1200.0 * delta)
	else:
		var friction = 2200.0 if is_on_floor() else 600.0
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func process_vertical_movement() -> void:
	# Bajar de plataformas semitransparentes (one-way) presionando Abajo + Salto
	if input_dir.y > 0.6 and input_jump and is_on_floor():
		position.y += 4.0
		input_jump = false
		return

	# Salto y Doble Salto
	if input_jump and jumps_left > 0 and not is_attacking:
		input_jump = false
		if jumps_left == max_jumps:
			velocity.y = jump_force
		else:
			velocity.y = double_jump_force
			
		jumps_left -= 1
		if visuals: visuals.trigger_jump_stretch()

	# Caída rápida si presiona abajo en el aire
	if input_dir.y > 0.7 and not is_on_floor() and velocity.y > 0:
		velocity.y = min(velocity.y + 400.0, fall_speed_max * 1.3)

func process_attacks() -> void:
	if is_attacking or is_hitstun:
		return
		
	if input_attack:
		input_attack = false
		is_attacking = true
		attack_normal()
	elif input_special:
		input_special = false
		is_attacking = true
		if input_dir.y < -0.4:
			attack_up_special()
		else:
			attack_neutral_special()

# Métodos a sobreescribir por los personajes
func attack_normal() -> void: pass
func attack_neutral_special() -> void: pass
func attack_up_special() -> void: pass

func finish_attack() -> void:
	if hitbox:
		hitbox.monitoring = false
	is_attacking = false

func _on_hurtbox_hit(incoming_hitbox: Hitbox) -> void:
	if is_invincible: return
	
	var dmg = incoming_hitbox.damage
	var atk_facing = incoming_hitbox.attacker.facing if incoming_hitbox.attacker else 1.0
	var kb_vec = incoming_hitbox.get_knockback_vector(damage_percent, atk_facing)
	var attacker_ref = incoming_hitbox.attacker
	var spark_color = incoming_hitbox.hit_spark_color
	
	apply_damage_and_knockback(dmg, kb_vec, attacker_ref, spark_color)

func take_hit_from_source(dmg: float, base_kb: float, kb_growth: float, dir: Vector2, attacker_ref: CharacterBody2D, spark_color: Color) -> void:
	if is_invincible: return
	var total_kb = base_kb + (damage_percent * kb_growth)
	var kb_vec = dir.normalized() * total_kb
	apply_damage_and_knockback(dmg, kb_vec, attacker_ref, spark_color)

func apply_damage_and_knockback(dmg: float, kb_vector: Vector2, _attacker_ref: CharacterBody2D, spark_color: Color) -> void:
	damage_percent += dmg
	damage_changed.emit(damage_percent)
	
	# Ajuste por peso del personaje
	var weight_factor = 100.0 / max(weight, 50.0)
	var final_kb = kb_vector * weight_factor
	velocity = final_kb
	
	# Activar Hitstun
	is_hitstun = true
	is_attacking = false
	if hitbox: hitbox.monitoring = false
	
	# Efectos visuales de impacto
	if visuals: visuals.trigger_hurt_flash()
	if trail_particles: trail_particles.emitting = true
	
	var stun_time = clamp(final_kb.length() / 1400.0, 0.22, 1.4)
	hitstun_timer.start(stun_time)
	
	# Spawns y Game Feel
	GameManager.spawn_hit_spark(global_position + Vector2(0, -25), spark_color, dmg / 10.0)
	GameManager.trigger_hitstop(clamp(dmg * 0.006, 0.04, 0.1))
	GameManager.trigger_camera_shake(clamp(final_kb.length() / 85.0, 4.0, 22.0))

func _on_hitstun_end() -> void:
	is_hitstun = false
	if trail_particles: trail_particles.emitting = false

func lose_stock() -> void:
	stocks -= 1
	stocks_changed.emit(stocks)

func respawn(spawn_pos: Vector2) -> void:
	global_position = spawn_pos
	velocity = Vector2.ZERO
	damage_percent = 0.0
	damage_changed.emit(damage_percent)
	is_hitstun = false
	is_attacking = false
	is_invincible = true
	jumps_left = max_jumps
	if trail_particles: trail_particles.emitting = false
	if invincibility_timer: invincibility_timer.start(2.5)

func configure_identity(p_idx: int, human: bool) -> void:
	player_index = p_idx
	is_human = human
	if visuals:
		match p_idx:
			0:
				visuals.player_label = "P1" if human else "CPU 1"
				visuals.label_color = Color(1.0, 0.2, 0.2)
			1:
				visuals.player_label = "CPU 1"
				visuals.label_color = Color(0.2, 0.5, 1.0)
			2:
				visuals.player_label = "CPU 2"
				visuals.label_color = Color(0.2, 0.9, 0.3)
			3:
				visuals.player_label = "CPU 3"
				visuals.label_color = Color(1.0, 0.85, 0.1)
