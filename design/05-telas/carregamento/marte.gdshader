shader_type spatial;
// Spinning Mars, made in code with the palette colors (design/02).
uniform sampler2D noise1;
uniform sampler2D noise2;
uniform vec3 color_dark : source_color = vec3(0.451, 0.141, 0.165);  // #73242A
uniform vec3 color_mid : source_color = vec3(0.851, 0.412, 0.255);   // #D96941
uniform vec3 color_light : source_color = vec3(0.949, 0.576, 0.361);   // #F2935C
uniform vec3 color_pole : source_color = vec3(0.949, 0.816, 0.569);    // #F2D091
uniform vec3 color_rim : source_color = vec3(0.910, 0.698, 0.227);   // #E8B23A

void fragment() {
	float n = texture(noise1, UV * vec2(2.0, 1.0)).r;
	float n2 = texture(noise2, UV * vec2(4.0, 2.0)).r;
	vec3 col = mix(color_dark, color_mid, smoothstep(0.42, 0.62, n) * 0.85);
	col = mix(col, color_light, smoothstep(0.55, 0.75, n2) * 0.5);
	float lat = abs(UV.y - 0.5) * 2.0;
	col = mix(col, color_pole, smoothstep(0.74, 0.82, lat + n2 * 0.1));
	ALBEDO = col;
	ROUGHNESS = 1.0;
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	EMISSION = color_rim * fres * 0.9;
}
