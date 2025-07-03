extends HBoxContainer

const PLAYER_PALETTE = preload("res://resources/player_palette.tres")

@onready var chosen_color_viewer: TextureRect = %ChosenColorViewer
var chosen_color: Color

func _ready() -> void:
	for color in PLAYER_PALETTE.colors:
		create_color_option(color)

func create_color_option(color: Color) -> void:
	var option := ColorRect.new()
	option.custom_minimum_size = Vector2(30, 30)
	option.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	option.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	option.color = color
	add_child(option)
	option.gui_input.connect(_on_color_option_input.bind(color))


func _on_color_option_input(event: InputEvent, color: Color) -> void:
	if event is InputEventMouseButton:
		chosen_color = color
		chosen_color_viewer.self_modulate = color
