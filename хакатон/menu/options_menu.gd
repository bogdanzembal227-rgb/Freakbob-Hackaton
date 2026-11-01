extends Control

signal back_pressed

@export var standalone: bool = true
@export_file("*.tscn") var main_menu_path: String = "res://menu/main_menu.tscn"

@onready var back_button: Button = %BackButton
@onready var background: ColorRect = %Background


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	visibility_changed.connect(_focus_back_button)
	# поверх гри білий фон не потрібен - там розмита гра
	background.visible = standalone
	_focus_back_button()


func _focus_back_button() -> void:
	if is_visible_in_tree():
		back_button.grab_focus()


func _on_back_pressed() -> void:
	if standalone:
		get_tree().change_scene_to_file(main_menu_path)
	else:
		back_pressed.emit()
