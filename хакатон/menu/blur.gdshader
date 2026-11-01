shader_type canvas_item;

// Бере те, що вже намальовано на екрані, і розмиває (через mip-рівні текстури).
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
// Сила розмиття: більше число = сильніше розмиття.
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;
// Колір і сила "затемнення" поверх розмитої гри (щоб кнопки краще читалися).
uniform vec4 tint_color : source_color = vec4(0.17, 0.2, 0.2, 1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE * pow(2.0, blur_amount);
	vec4 sum = vec4(0.0);
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			sum += textureLod(screen_texture, SCREEN_UV + vec2(float(x), float(y)) * px, blur_amount);
		}
	}
	vec3 blurred = (sum / 9.0).rgb;
	COLOR = vec4(mix(blurred, tint_color.rgb, tint_strength), 1.0);
}
