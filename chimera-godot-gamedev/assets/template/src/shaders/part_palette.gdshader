shader_type canvas_item;
// Imported art in "palette" mode: grayscale painting -> creature palette (dark/base/light ramp);
// saturated pixels (the generator's bright "glow" areas) -> element accent color.
// One painted part therefore fits ANY host race and element. Then gene layers are applied.

#include "res://src/shaders/gene_layers.gdshaderinc"

uniform vec4 base_color : source_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform vec4 dark_color : source_color = vec4(0.2, 0.2, 0.2, 1.0);
uniform vec4 accent_color : source_color = vec4(0.48, 0.82, 0.24, 1.0);
uniform bool palette_map = true;
uniform float alpha_mult = 1.0;

varying vec2 lp;

void vertex() {
	lp = VERTEX;
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 c = tex;
	if (palette_map) {
		float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
		float sat = max(tex.r, max(tex.g, tex.b)) - min(tex.r, min(tex.g, tex.b));
		vec3 deep = dark_color.rgb * 0.45;
		vec3 light = mix(base_color.rgb, vec3(1.0), 0.35);
		vec3 ramp = lum < 0.5 ? mix(deep, base_color.rgb, lum * 2.0) : mix(base_color.rgb, light, (lum - 0.5) * 2.0);
		vec3 acc = accent_color.rgb * (0.55 + 0.65 * lum);
		c.rgb = mix(ramp, acc, smoothstep(0.16, 0.32, sat));
	}
	c.a = tex.a * alpha_mult;
	COLOR = apply_gene_layers(c, lp, TIME);
}
