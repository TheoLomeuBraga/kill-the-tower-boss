// NOTE: Shader automatically converted from Godot Engine 4.6.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float fresnel_power = 1.0;


void fragment() {
	vec4 albedo_tex = texture(texture_albedo, SCREEN_UV * 100.0);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float fresnel = 1.0 - dot(NORMAL,VIEW);
	fresnel = clamp(fresnel * fresnel_power,0.0,1.0);
	ALPHA *= fresnel;
}
