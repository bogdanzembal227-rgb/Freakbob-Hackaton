extends Control

## Шляхи до сцен. Їх можна змінити прямо в Inspector.
@export_file("*.tscn") var level_path: String = "res://test_map/map.tscn"
@export_file("*.tscn") var options_path: String = "res://menu/options_menu.tscn"

@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	# щоб меню можна було гортати стрілками/Enter
	play_button.grab_focus()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(level_path)


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file(options_path)


func _on_exit_pressed() -> void:
	get_tree().quit()
