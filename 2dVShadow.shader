shader_type canvas_item;

uniform vec2 light_pos;
uniform float range_limit = 2000;
uniform float hw = 0.025 ; // 32/1280
uniform float hh = 0.0444444444444444; //   32/ 720


void fragment(){
	if (texture(TEXTURE,UV).xyz != vec3(0)){
		COLOR = texture(TEXTURE,UV);
	}
	else{
		vec2 ray_origin = vec2(0.5,0.5);
		vec2 dir = normalize(UV-ray_origin);
		ray_origin+=0.05*dir;
		float dist = distance(UV,ray_origin);
		float cur_range = 0.0;
		bool hit = false;
		while(cur_range<dist){
			ray_origin += 0.0005*dir;
			cur_range +=0.0005 ;
			if (texture(TEXTURE,ray_origin).xyz != vec3(0)){
				hit = true;
				break;
			}
		}
		if (hit ){
			COLOR = vec4(0);
		}
		else{
			COLOR = ((0.5-dist)/0.5)*vec4(1.0);
		}
	}
}