class_name CreatureView
extends Node2D
## Board piece / gallery specimen. Give it a VisualGenome dict via setup().
## Every part (and the body) uses imported art when art/parts/<kind>.png (art/bodies/<plan>.png)
## exists, otherwise the procedural placeholder from CreaturePainter. Mixing is fine, so art
## can be delivered one file at a time.
##   _rig            breathing / hover (everything below moves together)
##     _proc_back    procedural shadow + back parts            (gene_layers shader)
##     _back_sprites imported back parts                       (part_palette shader)
##     _body_sprite  imported body, if any                     (part_palette shader)
##     _proc_front   procedural body + remaining parts         (gene_layers shader)
##     _front_sprites imported skin/core/head/limb parts       (part_palette shader)
##   _fx             element particles + optional socket markers (unshaded)

const LAYER_SHADER := preload("res://src/shaders/gene_layers.gdshader")
const PALETTE_SHADER := preload("res://src/shaders/part_palette.gdshader")
## Gene material layers on full-colour illustrated art are toned down so faces stay clean.
const CUTOUT_LAYER_STRENGTH := 0.35
const FRONT_SLOT_ORDER := ["skin", "core", "head", "limb"]

var vg: Dictionary = {}
var races: Dictionary = {}
var facing: int = 1
var show_sockets: bool = false
var sockets: Dictionary = {}
var skip: Dictionary = {}  # part index -> true when drawn as a texture
var body_textured: bool = false
var _t: float = 0.0
var _rig: Node2D
var _proc_back: _Proc
var _proc_front: _Proc
var _back_sprites: Node2D
var _front_sprites: Node2D
var _body_sprite: Sprite2D
var _fx: _Fx


func setup(p_vg: Dictionary, p_races: Dictionary, p_facing: int = 1, base_scale: float = 1.0) -> void:
	vg = p_vg
	races = p_races
	facing = p_facing
	_t = randf() * 10.0  # cosmetic only: desync idle animations
	for c in get_children():
		c.queue_free()
	skip.clear()
	sockets = CreaturePainter.sockets_for(vg)
	var body_art := ArtLibrary.body(vg.get("body_plan", "biped"))
	body_textured = not body_art.is_empty()
	var layers: Dictionary = vg.get("layers", {})
	var seed_v := float(hash(vg.get("name", "")) % 97)

	_rig = Node2D.new()
	add_child(_rig)
	_proc_back = _Proc.new()
	_proc_back.owner_view = self
	_proc_back.back = true
	_proc_back.material = _layer_material(layers, seed_v)
	_rig.add_child(_proc_back)
	_back_sprites = Node2D.new()
	_rig.add_child(_back_sprites)
	if body_textured:
		var pal: Dictionary = vg.get("palette", {})
		_body_sprite = _make_sprite(body_art, pal.get("base", Color.GRAY), pal.get("dark", Color.BLACK),
			pal.get("accent", Color.WHITE), layers, seed_v, 1.0)
		_rig.add_child(_body_sprite)
	_proc_front = _Proc.new()
	_proc_front.owner_view = self
	_proc_front.material = _layer_material(layers, seed_v)
	_rig.add_child(_proc_front)
	_front_sprites = Node2D.new()
	_rig.add_child(_front_sprites)
	_fx = _Fx.new()
	_fx.owner_view = self
	add_child(_fx)

	var parts: Array = vg.get("parts", [])
	for slot: String in ["back"] + FRONT_SLOT_ORDER:
		for i in parts.size():
			var p: Dictionary = parts[i]
			if p.slot != slot:
				continue
			var art := ArtLibrary.part(p.kind)
			if art.is_empty():
				continue
			skip[i] = true
			var pc := CreaturePainter.part_colors(p, vg, races)
			var k := 1.0 if p.get("prominent", true) else 0.65
			var spr := _make_sprite(art, pc.fill, pc.dark, pc.glow, layers, seed_v, k)
			spr.position = CreaturePainter.anchor_point(sockets, p.get("socket", "core")) + (art.offset as Vector2)
			(_back_sprites if slot == "back" else _front_sprites).add_child(spr)

	var sc: float = base_scale * float(vg.get("scale", 1.0)) * (1.55 if vg.get("boss", false) else 1.0)
	scale = Vector2(sc * facing, sc)


func _make_sprite(art: Dictionary, base: Color, dark: Color, accent: Color, layers: Dictionary,
		seed_v: float, k: float) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = art.texture
	spr.centered = false
	spr.offset = -(art.pivot as Vector2)
	var s: float = float(art.scale) * k
	spr.scale = Vector2(s, s)
	spr.rotation = float(art.rotation)
	var mat := ShaderMaterial.new()
	mat.shader = PALETTE_SHADER
	mat.set_shader_parameter("base_color", base)
	mat.set_shader_parameter("dark_color", dark)
	mat.set_shader_parameter("accent_color", accent)
	var painted := str(art.get("mode", "palette")) != "palette"  # full-colour illustration (cutout)
	mat.set_shader_parameter("palette_map", not painted)
	mat.set_shader_parameter("layer_strength", CUTOUT_LAYER_STRENGTH if painted else 1.0)
	mat.set_shader_parameter("alpha_mult", 1.0 if k >= 1.0 else 0.9)
	for layer: String in Defs.LAYERS:
		if layer != "":
			mat.set_shader_parameter(layer, float(layers.get(layer, 0.0)))
	mat.set_shader_parameter("pattern_scale", 0.09 * s)  # keep pattern size in creature space
	mat.set_shader_parameter("seed", seed_v)
	spr.material = mat
	return spr


func _layer_material(layers: Dictionary, seed_v: float) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = LAYER_SHADER
	for layer: String in Defs.LAYERS:
		if layer != "":
			mat.set_shader_parameter(layer, float(layers.get(layer, 0.0)))
	mat.set_shader_parameter("seed", seed_v)
	return mat


func _process(delta: float) -> void:
	_t += delta
	if _rig == null:
		return
	var breathe := sin(_t * 2.0) * 0.015
	_rig.scale = Vector2(1.0 - breathe * 0.5, 1.0 + breathe)
	if vg.get("body_plan", "") in ["floater", "construct"]:
		_rig.position.y = sin(_t * 1.7) * 3.0
	_proc_back.queue_redraw()
	_proc_front.queue_redraw()
	_fx.queue_redraw()


class _Proc:
	extends Node2D
	var owner_view: CreatureView
	var back: bool = false

	func _draw() -> void:
		var v := owner_view
		if v.vg.is_empty():
			return
		if back:
			CreaturePainter.draw_back(self, v.vg, v.races, v._t, v.sockets, v.skip)
		else:
			CreaturePainter.draw_front(self, v.vg, v.races, v._t, v.sockets, v.skip, not v.body_textured)


class _Fx:
	extends Node2D
	var owner_view: CreatureView

	func _draw() -> void:
		var vg := owner_view.vg
		var s := owner_view.sockets
		if owner_view.show_sockets:
			for k: String in Defs.ART_SOCKETS:
				var p := CreaturePainter.anchor_point(s, k)
				draw_line(p + Vector2(-4, 0), p + Vector2(4, 0), Color(1, 0.3, 0.6), 1.5)
				draw_line(p + Vector2(0, -4), p + Vector2(0, 4), Color(1, 0.3, 0.6), 1.5)
		var fx: String = vg.get("fx", "")
		if fx == "" or s.is_empty():
			return
		var t := owner_view._t
		var col: Color = (vg.get("palette", {}) as Dictionary).get("accent", Color.WHITE)
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
