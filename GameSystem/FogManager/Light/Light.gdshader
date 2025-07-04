shader_type canvas_item;

uniform sampler2D curve;

void fragment() {
	float dist = (distance(UV, vec2(0.5)))*2.0; // 0~1
	dist = texture(curve, vec2(dist, 0.)).r;

	//const float SCALE = 7.;
	//dist = floor(dist*SCALE)/SCALE;

	COLOR.a = dist;

	COLOR.rgb = vec3(1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
