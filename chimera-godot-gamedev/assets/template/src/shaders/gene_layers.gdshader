shader_type canvas_item;
// Procedural (CanvasItem draw call) creature art + gene material layers.
// Layer logic lives in gene_layers.gdshaderinc (shared with imported art).

#include "res://src/shaders/gene_layers.gdshaderinc"

varying vec2 lp;

void vertex() {
	lp = VERTEX;
}

void fragment() {
	COLOR = apply_gene_layers(COLOR, lp, TIME);
}
