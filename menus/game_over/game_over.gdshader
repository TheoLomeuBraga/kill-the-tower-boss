shader_type canvas_item;

uniform float lod: hint_range(0.0, 5.0) = 5.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float gameover_progres : hint_range(0.0, 1.0, 0.01);
uniform sampler2D noise : filter_nearest;

void fragment(){
	vec4 blur = textureLod(screen_texture, SCREEN_UV, min(lod*(gameover_progres*2.0),5.0));
	float noise_progress = floor(texture(noise,SCREEN_UV).r + gameover_progres);
	noise_progress = clamp(0.0,1.0,noise_progress);
	COLOR = mix(blur,vec4(1.0,0.0,0.0,1.0),noise_progress);
}