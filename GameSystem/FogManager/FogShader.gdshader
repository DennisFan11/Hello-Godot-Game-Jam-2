shader_type canvas_item;

uniform vec4 color:source_color;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);

    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }
	COLOR = color;
	float fog = clamp(1.0-c.a, 0.0, 1.);
    COLOR.a *= fog;



}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
