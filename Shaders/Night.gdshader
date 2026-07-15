shader_type canvas_item;
uniform float mix : hint_range(0.0, 1.0, 0.1);
void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	vec4 output_color = mix(COLOR , vec4(0.0,0.0,0.0,1.0), mix);
	COLOR = vec4(output_color.rgb, input_color.a);
}
