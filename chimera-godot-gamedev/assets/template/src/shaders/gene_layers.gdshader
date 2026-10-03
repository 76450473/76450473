shader_type canvas_item;
// Gene material layers. Each uniform 0..1 = how far that layer has spread over the body.
// Low values give sparse patches (a few plates / threads), high values cover the creature:
// this is the "gradual expression" rule from references/visual-system.md.
// Dark outlines (luminance < 0.18) are never decorated, so silhouettes stay readable.

uniform float chitin : hint_range(0.0, 1.0) = 0.0;
uniform float mycelium : hint_range(0.0, 1.0) = 0.0;
uniform float crystal : hint_range(0.0, 1.0) = 0.0;
uniform float fur : hint_range(0.0, 1.0) = 0.0;
uniform float ether : hint_range(0.0, 1.0) = 0.0;
uniform float rot : hint_range(0.0, 1.0) = 0.0;
uniform vec4 chitin_tint : source_color = vec4(0.36, 0.11, 0.15, 1.0);
uniform vec4 mycelium_tint : source_color = vec4(0.93, 0.93, 0.85, 1.0);
uniform vec4 crystal_tint : source_color = vec4(0.62, 0.86, 1.0, 1.0);
uniform vec4 ether_tint : source_color = vec4(0.55, 0.95, 0.9, 1.0);
uniform vec4 rot_tint : source_color = vec4(0.27, 0.31, 0.12, 1.0);
uniform float pattern_scale = 0.09;
uniform float seed = 0.0;

varying vec2 lp;

void vertex() {
	lp = VERTEX;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// x = distance to nearest cell point, y = distance to second nearest
vec2 cells(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = vec2(hash(i + g), hash(i + g + 19.19));
			vec2 r = g + o - f;
			float d = dot(r, r);
			if (d < d1) {
				d2 = d1;
				d1 = d;
			} else if (d < d2) {
				d2 = d;
			}
		}
	}
	return vec2(sqrt(d1), sqrt(d2));
}

void fragment() {
	vec4 c = COLOR;
	float lum = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	float body = step(0.18, lum) * step(0.05, c.a);
	vec2 p = lp * pattern_scale + vec2(seed);
	if (chitin > 0.0) {
		vec2 cl = cells(p * 1.25);
		float seam = smoothstep(0.0, 0.07, cl.y - cl.x);
		float cover = step(1.0 - chitin, noise(p * 0.55 + 1.7));
		vec3 shell = mix(chitin_tint.rgb * 0.7, chitin_tint.rgb * 1.45, 1.0 - cl.x);
		shell = mix(chitin_tint.rgb * 0.3, shell, seam);
		c.rgb = mix(c.rgb, shell, cover * body * 0.85);
	}
	if (mycelium > 0.0) {
		float threads = 1.0 - smoothstep(0.0, 0.05, abs(noise(p * 2.6) - 0.5));
		float cover = step(1.0 - mycelium, noise(p * 0.5 + 7.0));
		c.rgb = mix(c.rgb, mycelium_tint.rgb, threads * cover * body * 0.85);
	}
	if (crystal > 0.0) {
		vec2 cl = cells(p * 0.9 + 3.0);
		float facet = fract(cl.x * 3.0 + cl.y);
		float cover = step(1.0 - crystal, noise(p * 0.5 + 13.0));
		vec3 cr = mix(crystal_tint.rgb * 0.75, vec3(1.0), smoothstep(0.75, 1.0, facet) * 0.7);
		c.rgb = mix(c.rgb, cr, cover * body * 0.75);
	}
	if (fur > 0.0) {
		float strands = noise(vec2(p.x * 7.0, p.y * 0.9));
		c.rgb = mix(c.rgb, c.rgb * mix(0.72, 1.18, strands), fur * body);
	}
	if (ether > 0.0) {
		float wave = 0.5 + 0.5 * sin(lp.y * 0.12 + TIME * 2.0 + noise(p) * 4.0);
		c.rgb = mix(c.rgb, ether_tint.rgb, wave * ether * body * 0.35);
		c.a *= mix(1.0, 0.72 + 0.28 * wave, ether);
	}
	if (rot > 0.0) {
		float blot = smoothstep(0.52, 0.68, noise(p * 1.3 + 21.0));
		c.rgb = mix(c.rgb, rot_tint.rgb, blot * rot * body * 0.8);
	}
	COLOR = c;
}
