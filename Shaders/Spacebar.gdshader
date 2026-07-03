shader_type canvas_item;

void fragment() {
	vec4 Input_color = texture(TEXTURE, UV);
	COLOR = vec4(0.58,0.58,0.58,Input_color.a);
}