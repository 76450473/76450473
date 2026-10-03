class_name CreatureView
extends Node2D
## Board piece / gallery specimen. Give it a VisualGenome dict via setup().
## Body is drawn by CreaturePainter (placeholder art) through the gene_layers shader;
## element FX are drawn on a separate unshaded child so glows stay clean.

const LAYER_SHADER := preload("res://src/shaders/gene_layers.gdshader")

var vg: Dictionary = {}
var races: Dictionary = {}
var facing: int = 1
var _t: float = 0.0
var _body: _Body
var _fx: _Fx


func setup(p_vg: Dictionary, p_races: Dictionary, p_facing: int = 1, base_scale: float = 1.0) -> void:
	vg = p_vg
	races = p_races
	facing = p_facing
	_t = randf() * 10.0  # cosmetic only: desync idle animations
	if _body == null:
		_body = _Body.new()
		_body.owner_view = self
		add_child(_body)
		_fx = _Fx.new()
		_fx.owner_view = self
		add_child(_fx)
	var mat := ShaderMaterial.new()
	mat.shader = LAYER_SHADER
	for layer: String in Defs.LAYERS:
		if layer != "":
			mat.set_shader_parameter(layer, float((vg.get("layers", {}) as Dictionary).get(layer, 0.0)))
	mat.set_shader_parameter("seed", float(hash(vg.get("name", "")) % 97))
	_body.material = mat
	var sc: float = base_scale * float(vg.get("scale", 1.0)) * (1.55 if vg.get("boss", false) else 1.0)
	scale = Vector2(sc * facing, sc)
	_body.queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	if _body == null:
		return
	var breathe := sin(_t * 2.0) * 0.015
	_body.scale = Vector2(1.0 - breathe * 0.5, 1.0 + breathe)
	if vg.get("body_plan", "") in ["floater", "construct"]:
		_body.position.y = sin(_t * 1.7) * 3.0
	_body.queue_redraw()
	_fx.queue_redraw()


class _Body:
	extends Node2D
	var owner_view: CreatureView

	func _draw() -> void:
		if owner_view.vg.is_empty():
			return
		CreaturePainter.draw_creature(self, owner_view.vg, owner_view.races, owner_view._t)


class _Fx:
	extends Node2D
	var owner_view: CreatureView

	func _draw() -> void:
		var vg := owner_view.vg
		var fx: String = vg.get("fx", "")
		if fx == "":
			return
		var t := owner_view._t
		var col: Color = (vg.get("palette", {}) as Dictionary).get("accent", Color.WHITE)
		var s := CreaturePainter.sockets(vg.get("body_plan", "biped"))
		var core: Vector2 = s.core
		match fx:
			"poison":
				for i in 4:
					var ph := fmod(t * 0.7 + i * 0.25, 1.0)
					draw_circle(core + Vector2(-14 + i * 9, ph * 60), 2.6 * (1.0 - ph), Color(col, 0.85 * (1.0 - ph)))
			"infect":
				for i in 7:
					var ph := fmod(t * 0.35 + i * 0.143, 1.0)
					var p := core + Vector2(sin(i * 2.1 + t) * 24, -ph * 80)
					draw_circle(p, 2.0, Color(col, 0.7 * (1.0 - ph)))
			"regen":
				var ph := fmod(t * 0.8, 1.0)
				draw_arc(core, 18 + ph * 26, 0, TAU, 32, Color(col, 0.5 * (1.0 - ph)), 2.0, true)
			"stun":
				var head: Vector2 = s.head
				for i in 3:
					var a := t * 3.0 + i * TAU / 3.0
					draw_circle(head + Vector2(cos(a) * 18, -s.head_r - 6 + sin(a) * 5), 2.4, col)
			"vulnerable":
				var ph := fmod(t * 0.6, 1.0)
				draw_arc(s.torso, 30, -1.2, 1.2, 12, Color(col, 0.6 * (1.0 - ph)), 2.0, true)
			"summon":
				var ph := fmod(t * 0.5, 1.0)
				draw_circle(s.back + Vector2(0, -10 - ph * 20), 3.0, Color(col, 1.0 - ph))
