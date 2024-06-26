shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec2 scale;
uniform float y_zoom;

uniform vec4 water_color : source_color;
uniform sampler2D noise;
uniform vec2 distortion_scale;
uniform float intensity;
uniform float speed;

void fragment() {
	
	float distortion = texture(noise, UV * scale * distortion_scale + TIME * speed).x;
	distortion -= 0.5;
	
	float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 reflected_screen_uv = vec2(SCREEN_UV.x - (distortion * intensity * y_zoom), SCREEN_UV.y - uv_height * UV.y * y_zoom * scale.y * 2.0);
	
	vec4 reflection = texture(SCREEN_TEXTURE, reflected_screen_uv);
	
	COLOR.rgb = mix(reflection.rgb, water_color.rgb, water_color.a);
}
