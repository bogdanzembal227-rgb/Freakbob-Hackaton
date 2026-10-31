shader_type canvas_item;

// Бере те, що вже намальовано на екрані, і розмиває (через mip-рівні текстури).
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
// Сила розмиття: більше число = сильніше розмиття.
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
// Наскільки "забілити" картинку, щоб чорні кнопки краще читалися (0 = не білити).
uniform float tint_strength : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE * pow(2.0, blur_amount);
	vec4 sum = vec4(0.0);
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			sum += textureLod(screen_texture, SCREEN_UV + vec2(float(x), float(y)) * px, blur_amount);
		}
	}
	vec3 blurred = (sum / 9.0).rgb;
	COLOR = vec4(mix(blurred, vec3(1.0), tint_strength), 1.0);
}
