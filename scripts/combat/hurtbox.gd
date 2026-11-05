extends Area2D
class_name Hurtbox

signal hit_received(hitbox: Hitbox)

var character: CharacterBody2D = null

func _ready() -> void:
	character = get_owner() as CharacterBody2D
	if not character and get_parent() is CharacterBody2D:
		character = get_parent() as CharacterBody2D
	# Capa 4 (Hurtbox = 8), Máscara 16 (Hitbox)
	collision_layer = 8
	collision_mask = 16
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		# Ignorar ataques propios
		if area.attacker == character:
			return
		hit_received.emit(area)
