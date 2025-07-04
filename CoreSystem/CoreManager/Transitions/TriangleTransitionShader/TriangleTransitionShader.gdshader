shader_type canvas_item;
render_mode unshaded;

float polygon_shape(vec2 uv, int sides, float width, float height) {
	float a_width = width * cos(PI / float(sides));
	float a_height = height * cos(PI / float(sides));
	uv = (uv * 2.0 - 1.0) / vec2(a_width, a_height);
	uv.y *= -1.0;
	float polar_coords = atan(uv.x, uv.y);
	float radius = 2.0 * PI / float(sides);
	float dist = cos(floor(0.5 + polar_coords / radius) * radius - polar_coords) * length(uv);
	return clamp((1.0 - dist) / fwidth(dist), 0.0, 1.0);
}

uniform float EDGE = 1.0;
void fragment() {

	vec2 fixed_uv = fract(UV * 10.);
    float a = polygon_shape(fixed_uv, 3, 1.0, 1.0);

	float fixed_edge = EDGE/10.;
	vec2 fixed_uv2 = fract(( UV + vec2(fixed_edge/2.0) ) * 10.);
	fixed_uv2.y = 1.0-fixed_uv2.y;
	float b = polygon_shape(fixed_uv2, 3, 1.0, 1.0);

    COLOR = vec4(a,b,0., 1.0);
	//COLOR.rg = uv;
}
