shader_type canvas_item;

uniform vec4 color = vec4(1.0f,1.0f,1.0f,1.0f);
uniform float thickness = 0.02f;


void fragment(){
	vec2 center = vec2(0.5f, 0.5f) ;
	float dist = distance(UV,center);
	float r = 0.4f + sin(TIME*10.0f)*0.08;
	//if (dist<= (r - rand(vec2(dist,dist))))
	if (dist< (r + thickness) && dist>r)
	{
		COLOR = color;
	}
	else
	{
		COLOR = vec4(0);
	}
}
