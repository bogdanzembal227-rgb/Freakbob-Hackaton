extends CanvasLayer

## Кнопка зліва вгорі відкриває меню поверх гри (гра на паузі й розмита).
## Esc теж відкриває/закриває меню.

## Сцена головного меню (EXIT повертає сюди). Можна змінити в Inspector.
@export_file("*.tscn") var main_menu_path: String = "res://menu/main_menu.tscn"

@onready var open_button: TextureButton = %OpenButton
@onready var overlay: Control = %Overlay
@onready var main_buttons: Control = %MainButtons
@onready var options_menu: Control = %OptionsMenu
@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	open_button.pressed.connect(open_menu)
	play_button.pressed.connect(close_menu)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	options_menu.connect("back_pressed", _on_options_back)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if options_menu.visible:
		_on_options_back()
	elif overlay.visible:
		close_menu()
	else:
		open_menu()


func open_menu() -> void:
	get_tree().paused = true  # гра зупиняється
	open_button.hide()
	overlay.show()
	play_button.grab_focus()


func close_menu() -> void:
	overlay.hide()
	open_button.show()
	get_tree().paused = false  # гра продовжується


func _on_options_pressed() -> void:
	main_buttons.hide()
	options_menu.show()


func _on_options_back() -> void:
	options_menu.hide()
	main_buttons.show()
	options_button.grab_focus()


func _on_exit_pressed() -> void:
	# Спочатку знімаємо паузу, інакше головне меню теж буде "на паузі" і кнопки не спрацюють
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)
