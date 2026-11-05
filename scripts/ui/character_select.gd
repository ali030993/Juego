extends Control
class_name CharacterSelect

@onready var grid_container: GridContainer = $Margin/VBox/MainHBox/RosterPanel/GridContainer
@onready var preview_name: Label = $Margin/VBox/MainHBox/PreviewPanel/VBox/NameLabel
@onready var preview_title: Label = $Margin/VBox/MainHBox/PreviewPanel/VBox/TitleLabel
@onready var preview_desc: Label = $Margin/VBox/MainHBox/PreviewPanel/VBox/DescLabel
@onready var preview_badge: ColorRect = $Margin/VBox/MainHBox/PreviewPanel/VBox/BadgeContainer/Badge
@onready var preview_symbol: Label = $Margin/VBox/MainHBox/PreviewPanel/VBox/BadgeContainer/Badge/SymbolLabel
@onready var start_button: Button = $Margin/VBox/Footer/StartButton

var current_idx: int = 0
var buttons: Array[Button] = []

func _ready() -> void:
	create_roster_buttons()
	select_character(GameManager.selected_fighter_idx)
	start_button.pressed.connect(_on_start_pressed)

func create_roster_buttons() -> void:
	for i in range(GameManager.ROSTER.size()):
		var data = GameManager.ROSTER[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(160, 110)
		btn.text = "%s\n[%s]" % [data["name"], data["title"]]
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(data["color"].r * 0.3, data["color"].g * 0.3, data["color"].b * 0.3, 0.9)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = data["color"]
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", style)
		
		var idx = i
		btn.pressed.connect(func(): select_character(idx))
		grid_container.add_child(btn)
		buttons.append(btn)

func select_character(idx: int) -> void:
	current_idx = idx
	GameManager.selected_fighter_idx = idx
	var data = GameManager.ROSTER[idx]

	preview_name.text = data["name"].to_upper()
	preview_name.modulate = data["accent"]
	
	preview_title.text = "« " + data["title"] + " »"
	preview_desc.text = data["description"]
	
	preview_badge.color = data["color"]
	preview_symbol.text = data["name"].substr(0, 1)

	# Resaltar botón seleccionado
	for i in range(buttons.size()):
		var b = buttons[i]
		if i == idx:
			b.modulate = Color(1.3, 1.3, 1.3, 1.0)
		else:
			b.modulate = Color(0.8, 0.8, 0.8, 0.8)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/stages/Battlefield.tscn")

