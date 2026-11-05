extends Node
class_name PlayerController

var fighter: FighterBase

func _ready() -> void:
	fighter = get_parent() as FighterBase

func _process(_delta: float) -> void:
	if not fighter:
		fighter = get_parent() as FighterBase
	if not fighter: return
	
	var move_x: float = 0.0
	if is_act_pressed("p1_right") or Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move_x += 1.0
	if is_act_pressed("p1_left") or Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move_x -= 1.0
		
	var move_y: float = 0.0
	if is_act_pressed("p1_down") or Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move_y += 1.0
	if is_act_pressed("p1_up") or Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move_y -= 1.0
		
	fighter.input_dir = Vector2(move_x, move_y)
	
	# Salto: Espacio, W, Flecha Arriba
	if is_act_just_pressed("p1_jump") or Input.is_key_pressed(KEY_SPACE) or Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_accept"):
		fighter.input_jump = true
		
	# Ataque Normal: J, Z
	if is_act_just_pressed("p1_attack") or Input.is_key_pressed(KEY_J) or Input.is_key_pressed(KEY_Z):
		fighter.input_attack = true
		
	# Ataque Especial: K, X
	if is_act_just_pressed("p1_special") or Input.is_key_pressed(KEY_K) or Input.is_key_pressed(KEY_X):
		fighter.input_special = true

func is_act_pressed(action_name: String) -> bool:
	if InputMap.has_action(action_name):
		return Input.is_action_pressed(action_name)
	return false

func is_act_just_pressed(action_name: String) -> bool:
	if InputMap.has_action(action_name):
		return Input.is_action_just_pressed(action_name)
	return false
