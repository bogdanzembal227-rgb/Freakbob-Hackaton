shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.2, 1.0, 0.3, 1.0);
uniform float glow_amount : hint_range(0.0, 1.0) = 1.0;
uniform float pulse_speed = 4.0;
uniform bool active = true;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    if (active) {
        float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
        col.rgb += glow_color.rgb * glow_amount * mix(0.4, 1.0, pulse) * col.a;
    }
    COLOR = col;
}