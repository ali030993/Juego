extends CanvasLayer
class_name BattleUI

@onready var cards_container: HBoxContainer = $MarginContainer/BottomBar/CardsContainer
@onready var victory_panel: Panel = $VictoryPanel
@onready var winner_label: Label = $VictoryPanel/VBox/WinnerLabel
@onready var restart_btn: Button = $VictoryPanel/VBox/RestartBtn
@onready var select_btn: Button = $VictoryPanel/VBox/SelectBtn

var fighter_cards: Array[Dictionary] = []

func _ready() -> void:
	victory_panel.visible = false
	restart_btn.pressed.connect(func(): get_tree().reload_current_scene())
	select_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/CharacterSelect.tscn"))

func setup_hud(fighters: Array) -> void:
	# Limpiar tarjetas existentes
	for child in cards_container.get_children():
		child.queue_free()
	fighter_cards.clear()

	for f in fighters:
		var fighter = f as FighterBase
		var card = create_fighter_card(fighter)
		cards_container.add_child(card["root"])
		fighter_cards.append(card)

func create_fighter_card(fighter: FighterBase) -> Dictionary:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(240, 110)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.16, 0.88)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_bottom = 4
	style.border_color = fighter.visuals.accent_color if fighter.visuals else Color.WHITE
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# Fila 1: Etiqueta (P1/CPU) y Nombre del personaje
	var header = HBoxContainer.new()
	var tag_lbl = Label.new()
	tag_lbl.text = " P1 " if fighter.is_human else " CPU %d " % fighter.player_index
	tag_lbl.modulate = fighter.visuals.label_color if fighter.visuals else Color.WHITE
	header.add_child(tag_lbl)

	var name_lbl = Label.new()
	name_lbl.text = fighter.fighter_name.to_upper()
	name_lbl.modulate = fighter.visuals.accent_color if fighter.visuals else Color.WHITE
	header.add_child(name_lbl)
	vbox.add_child(header)

	# Fila 2: Porcentaje de daño Smash
	var percent_lbl = Label.new()
	percent_lbl.text = "0%"
	percent_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent_lbl.add_theme_font_size_override("font_size", 34)
	vbox.add_child(percent_lbl)

	# Fila 3: Vidas (Stocks)
	var stocks_lbl = Label.new()
	stocks_lbl.text = "❤❤❤"
	stocks_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stocks_lbl.modulate = Color(1.0, 0.3, 0.3)
	vbox.add_child(stocks_lbl)

	# Conectar señales del luchador
	fighter.damage_changed.connect(func(dmg):
		percent_lbl.text = "%d%%" % int(dmg)
		# Tinte dinámico de color según el daño
		if dmg < 40.0:
			percent_lbl.modulate = Color.WHITE
		elif dmg < 80.0:
			percent_lbl.modulate = Color(1.0, 0.9, 0.2) # Amarillo
		elif dmg < 120.0:
			percent_lbl.modulate = Color(1.0, 0.5, 0.1) # Naranja
		else:
			percent_lbl.modulate = Color(1.0, 0.2, 0.2) # Rojo crítico
	)

	fighter.stocks_changed.connect(func(stk):
		var hearts = ""
		for i in range(stk):
			hearts += "❤"
		if stk <= 0:
			stocks_lbl.text = "K.O."
			stocks_lbl.modulate = Color.DARK_GRAY
			panel.modulate = Color(0.6, 0.6, 0.6, 0.6)
		else:
			stocks_lbl.text = hearts
	)

	return {
		"fighter": fighter,
		"root": panel,
		"percent_lbl": percent_lbl,
		"stocks_lbl": stocks_lbl
	}

func show_victory(winner_name: String, is_player: bool) -> void:
	victory_panel.visible = true
	if is_player:
		winner_label.text = "¡VICTORIA!\n" + winner_name.to_upper() + " ES EL CAMPEÓN"
		winner_label.modulate = Color(0.3, 1.0, 0.4)
	else:
		winner_label.text = "¡FIN DEL COMBATE!\nGANADOR: " + winner_name.to_upper()
		winner_label.modulate = Color(1.0, 0.8, 0.2)

