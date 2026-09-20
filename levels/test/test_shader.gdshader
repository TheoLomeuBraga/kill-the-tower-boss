shader_type spatial;

uniform float amplitude :hint_range(0, 10.0) = 2.0;
uniform float velocidade = 2.0;
uniform float velocidade_hit = 10.0;
instance uniform bool hit = false;

void vertex() {
	VERTEX.y += sin(TIME*velocidade)*amplitude;
}

void fragment() {
	vec2 uv = (UV*2.0-1.0);
	
	float  w = (sqrt(uv.x)-1.0-sqrt(1.0-pow(uv.x,2.0)))/2.0;
	float u = (-sqrt(1.0-pow(uv.x,2.0))+sqrt(-uv.x)-1.0)/2.0;
	float n = (sqrt(1.0-pow(uv.x,2.0))+sqrt(uv.x*-1.0)-1.0);
	float g = sqrt(1.0-pow(uv.x,2.0))+sqrt(uv.x)-1.0;
	
	if((uv.y >= -w || uv.y >= -u || uv.y <= -n || uv.y <= -g)) {
		discard;
	}	
	
	if(!hit){
		ALBEDO = vec3(1.0,0.0,0.0);
	}else{
		float x = sin(TIME*velocidade_hit)+1.0;
		ALBEDO = vec3(1.0,0.0,0.0);
		ALPHA = x;
	}
}
