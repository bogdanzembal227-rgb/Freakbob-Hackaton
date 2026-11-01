extends TextureButton

## Кнопка-картинка не має станів "наведено/натиснуто", тому трохи міняємо яскравість самі.

func _process(_delta: float) -> void:
	var tint := Color.WHITE
	match get_draw_mode():
		DRAW_PRESSED, DRAW_HOVER_PRESSED:
			tint = Color(0.7, 0.7, 0.7)
		DRAW_HOVER:
			tint = Color(1.3, 1.3, 1.3)
	if has_focus() and tint == Color.WHITE:
		tint = Color(1.15, 1.15, 1.15)  # підсвічуємо кнопку, вибрану клавіатурою
	modulate = tint
