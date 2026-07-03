shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float aberration_x : hint_range(-1.0, 1.0) = 0.04;
uniform float aberration_y : hint_range(-1.0, 1.0) = 0.04;

vec3 aberr(vec2 uv){
	vec2 pixel_size = 1.0/vec2(textureSize(SCREEN_TEXTURE, 0));
	vec2 offset = vec2(aberration_x * pixel_size.x, aberration_y * pixel_size.y) * 100.0;
	vec3 final = vec3(texture(SCREEN_TEXTURE, uv+offset).r,texture(SCREEN_TEXTURE, uv).g,texture(SCREEN_TEXTURE, uv-offset).b);
	return final;
}

uniform sampler2D ST : hint_screen_texture, filter_linear_mipmap_anisotropic;
uniform vec4 scanline_color : source_color = vec4(0, 0, 0, 1);
uniform vec4 flicker_color : source_color = vec4(0, 0, 0, 1);
uniform float scanlines_count = 10.0;
uniform float scanlines_intensity = 0.05;
uniform float flicker_speed = 30.0;
uniform float flicker_intensity : hint_range(0.0, 1.0, 0.001) = 0.025;
uniform float color_offset = 1.5;
uniform float blurVHS = 0.15;

vec4 VHS(vec2 Screen, vec2 uv, vec4 fragcord) {
	vec2 pixel_size = 1.0 / vec2(textureSize(ST, 0));
	float offset = color_offset * pixel_size.x;
	
	// chromatic aberration
	float channel_r = textureLod(ST, Screen + vec2(offset, 0.0), blurVHS).r;
	float channel_g = textureLod(ST, Screen, blurVHS).g;
	float channel_b = textureLod(ST, Screen + vec2(-offset, 0.0), blurVHS).b;
	vec4 aberrate = vec4(channel_r, channel_g, channel_b, 1.0);
	
	// scanline flicker
	float mix_value = sin((Screen.y - (TIME * flicker_speed)) * 10.0) * flicker_intensity;
	vec4 flicker = mix(aberrate, flicker_color, mix_value);

	// scanlines
	float scanlines = sin(fragcord.y * scanlines_count) * scanlines_intensity;
	vec4 final = mix(flicker, scanline_color, scanlines);
	
	return final;
}

uniform float mixrate :hint_range(0.0,1.0) = 0.5;

void fragment() {
	
	vec4 Output_color = vec4(mix(aberr(SCREEN_UV), VHS(SCREEN_UV,UV,FRAGCOORD).rgb, mixrate),VHS(SCREEN_UV,UV,FRAGCOORD).a);
	COLOR = Output_color;
}