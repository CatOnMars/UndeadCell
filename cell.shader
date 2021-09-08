shader_type canvas_item;

uniform vec4 color = vec4(1.0f,1.0f,1.0f,1.0f);
uniform float r = 0.4f;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment(){
	vec2 center = vec2(0.5f, 0.5f) ;
	float dist = distance(UV,center);
	float rr = r + sin(TIME*10.0f)*0.08;
	//if (dist<= (r - rand(vec2(dist,dist))))
	if (dist<= rr)
	{
		COLOR = color;
	}
	else
	{
		COLOR = vec4(0);
	}
}