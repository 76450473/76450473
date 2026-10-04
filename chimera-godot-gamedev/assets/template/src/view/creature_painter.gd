class_name CreaturePainter
extends RefCounted
## Procedural placeholder art: draws a creature from a VisualGenome with CanvasItem draw calls.
## Every part is drawn in the shape language of the race the GENE came from, so a human with
## insect genes visibly carries insect anatomy. Replace any part with real art later by giving
## it a texture in res://art/parts/<kind>.png (see references/visual-system.md) — the sockets
## and z-order defined here stay the contract.
## Coordinates: origin = feet center, creature faces +x, ~150px tall at scale 1.

const OUTLINE_W := 2.6
const LIGHT := Vector2(-0.35, -0.65)


# ---------------------------------------------------------------- geometry helpers

static func ellipse(c: Vector2, rx: float, ry: float, n: int = 28, rot: float = 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry).rotated(rot))
	return pts


static func blob(c: Vector2, r: float, wobble: float, seed_v: float, n: int = 22) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		var k := 1.0 + wobble * (0.6 * sin(seed_v * 12.9 + i * 2.399) + 0.4 * sin(seed_v * 3.1 + i * 5.1))
		pts.append(c + Vector2(cos(a), sin(a)) * r * k)
	return pts


static func capsule(a: Vector2, b: Vector2, ra: float, rb: float, n: int = 8) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var ang := (b - a).angle()
	for i in n + 1:
		var t := ang - PI / 2 + PI * i / n
		pts.append(b + Vector2(cos(t), sin(t)) * rb)
	for i in n + 1:
		var t := ang + PI / 2 + PI * i / n
		pts.append(a + Vector2(cos(t), sin(t)) * ra)
	return pts


static func ngon(c: Vector2, r: float, n: int, rot: float = 0.0, squash: float = 1.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := rot + TAU * i / n
		pts.append(c + Vector2(cos(a) * r, sin(a) * r * squash))
	return pts


static func centroid(pts: PackedVector2Array) -> Vector2:
	var c := Vector2.ZERO
	for p in pts:
		c += p
	return c / maxf(1.0, pts.size())


static func shape(ci: CanvasItem, pts: PackedVector2Array, fill: Color, outline: Color, w: float = OUTLINE_W) -> void:
	if pts.size() < 3:
		return
	ci.draw_colored_polygon(pts, fill)
	var closed := pts.duplicate()
	closed.append(pts[0])
	ci.draw_polyline(closed, outline, w, true)


## Fill + soft highlight toward the light: cheap volume that reads well at board scale.
static func shaded(ci: CanvasItem, pts: PackedVector2Array, fill: Color, outline: Color, w: float = OUTLINE_W) -> void:
	shape(ci, pts, fill, outline, w)
	var c := centroid(pts)
	var size := 0.0
	for p in pts:
		size = maxf(size, (p - c).length())
	var hl := PackedVector2Array()
	for p in pts:
		hl.append(c + (p - c) * 0.52 + LIGHT * size * 0.22)
	var hc := fill.lightened(0.3)
	hc.a = 0.55 * fill.a
	ci.draw_colored_polygon(hl, hc)


static func limb(ci: CanvasItem, pts: Array, r0: float, r1: float, fill: Color, outline: Color) -> void:
	for i in pts.size() - 1:
		var t0 := float(i) / (pts.size() - 1)
		var t1 := float(i + 1) / (pts.size() - 1)
		shape(ci, capsule(pts[i], pts[i + 1], lerpf(r0, r1, t0), lerpf(r0, r1, t1)), fill, outline, OUTLINE_W * 0.85)


# ---------------------------------------------------------------- palette

static func colors(vg: Dictionary) -> Dictionary:
	var pal: Dictionary = vg.palette
	var base: Color = pal.base
	var dark: Color = pal.dark
	return {"base": base, "dark": dark, "accent": pal.accent, "far": base.darkened(0.28),
		"line": dark.darkened(0.55), "belly": base.lightened(0.12)}


static func part_colors(part: Dictionary, vg: Dictionary, races: Dictionary) -> Dictionary:
	var rp: Dictionary = races.get(part.race, {}).get("palette", {})
	var own := Color(rp.get("base", "#888888"))
	var base: Color = (vg.palette.base as Color)
	var fill := own.lerp(base, 0.25)
	var el: String = part.get("element", "none")
	var glow: Color = Color(Defs.ELEMENT_COLOR[el]) if Defs.ELEMENT_COLOR.has(el) else Color(rp.get("accent", "#ffffff"))
	if not part.get("prominent", true):
		fill = fill.lerp(base, 0.35)
	return {"fill": fill, "dark": Color(rp.get("dark", "#222222")), "glow": glow,
		"line": Color(rp.get("dark", "#222222")).darkened(0.5)}


# ---------------------------------------------------------------- sockets per body plan

static func sockets(plan: String) -> Dictionary:
	match plan:
		"hexapod":
			return {"head": Vector2(30, -50), "head_r": 12.0, "back": Vector2(-12, -60), "core": Vector2(-30, -38),
				"limb": Vector2(36, -26), "torso": Vector2(0, -42), "eye": Vector2(36, -53)}
		"cluster":
			return {"head": Vector2(0, -104), "head_r": 14.0, "back": Vector2(-30, -82), "core": Vector2(0, -44),
				"limb": Vector2(22, -40), "torso": Vector2(0, -50), "eye": Vector2(12, -74)}
		"quadruped":
			return {"head": Vector2(46, -68), "head_r": 15.0, "back": Vector2(-6, -66), "core": Vector2(-2, -46),
				"limb": Vector2(30, -12), "torso": Vector2(0, -46), "eye": Vector2(52, -72)}
		"construct":
			return {"head": Vector2(0, -122), "head_r": 13.0, "back": Vector2(0, -92), "core": Vector2(0, -76),
				"limb": Vector2(34, -64), "torso": Vector2(0, -76), "eye": Vector2(4, -122)}
		"floater":
			return {"head": Vector2(0, -108), "head_r": 16.0, "back": Vector2(-6, -86), "core": Vector2(0, -74),
				"limb": Vector2(28, -66), "torso": Vector2(0, -74), "eye": Vector2(6, -108)}
		_:  # biped
			return {"head": Vector2(2, -114), "head_r": 14.0, "back": Vector2(-6, -90), "core": Vector2(0, -74),
				"limb": Vector2(28, -58), "torso": Vector2(0, -74), "eye": Vector2(8, -116)}


# ---------------------------------------------------------------- main entry

## Sockets for this creature: defaults per body plan, overridden by an imported body's
## sidecar "sockets" (art/bodies/<plan>.json). Adds "textured_body" when body art exists.
static func sockets_for(vg: Dictionary) -> Dictionary:
	var s := sockets(vg.get("body_plan", "biped"))
	var body := ArtLibrary.body_for(vg)
	if not body.is_empty():
		s["textured_body"] = true
		var over: Dictionary = body.get("sockets", {})
		for k: String in over:
			s[k] = over[k]
	return s


## Where a textured part of a given socket name is pinned (see data/art_manifest.json parts.*.socket).
static func anchor_point(s: Dictionary, socket_name: String) -> Vector2:
	var head: Vector2 = s.head
	var r: float = s.head_r
	match socket_name:
		"head_top":
			return head + Vector2(-4, -r + 2)
		"mouth":
			return head + Vector2(r - 2, 6)
		"halo":
			return head + Vector2(0, -r - 10)
		"eye_top":
			return (s.eye as Vector2) + Vector2(0, -6)
	return s.get(socket_name, s.core)


static func draw_creature(ci: CanvasItem, vg: Dictionary, races: Dictionary, t: float) -> void:
	var s := sockets(vg.body_plan)
	draw_back(ci, vg, races, t, s, {})
	draw_front(ci, vg, races, t, s, {}, true)


## Shadow + back-slot parts (behind the body). `skip` = part indices drawn as textures instead.
static func draw_back(ci: CanvasItem, vg: Dictionary, races: Dictionary, t: float, s: Dictionary, skip: Dictionary) -> void:
	ci.draw_colored_polygon(ellipse(Vector2(0, 2), 46, 9), Color(0, 0, 0, 0.28))
	_draw_parts(ci, vg.parts, "back", s, vg, races, t, skip)


## Procedural body (unless body art exists) + skin/core/head/limb parts not drawn as textures.
static func draw_front(ci: CanvasItem, vg: Dictionary, races: Dictionary, t: float, s: Dictionary,
		skip: Dictionary, draw_body: bool) -> void:
	var col := colors(vg)
	var parts: Array = vg.parts
	var has_head_part := false
	for p: Dictionary in parts:
		if p.slot == "head" and p.kind in ["eye_compound", "prism"]:
			has_head_part = true
	if draw_body:
		match vg.body_plan:
			"hexapod":
				_body_hexapod(ci, col, vg.shape, t)
			"cluster":
				_body_cluster(ci, col, vg.shape, t)
			"quadruped":
				_body_quadruped(ci, col, vg.shape, t)
			"construct":
				_body_construct(ci, col, t)
			"floater":
				_body_floater(ci, col, t)
			_:
				_body_biped(ci, col, vg.shape, t, _has_slot(parts, "limb"))
	_draw_parts(ci, parts, "skin", s, vg, races, t, skip)
	_draw_parts(ci, parts, "core", s, vg, races, t, skip)
	if draw_body and not has_head_part:
		_default_eyes(ci, s, col, vg.body_plan)
	_draw_parts(ci, parts, "head", s, vg, races, t, skip)
	_draw_parts(ci, parts, "limb", s, vg, races, t, skip)


static func _has_slot(parts: Array, slot: String) -> bool:
	for p: Dictionary in parts:
		if p.slot == slot:
			return true
	return false


static func _default_eyes(ci: CanvasItem, s: Dictionary, col: Dictionary, plan: String) -> void:
	var e: Vector2 = s.eye
	var glow: Color = col.accent
	if plan == "floater":
		ci.draw_circle(e + Vector2(-5, 0), 3.6, glow)
		ci.draw_circle(e + Vector2(5, 0), 3.6, glow)
		return
	ci.draw_circle(e, 3.2, Color(0.08, 0.06, 0.08))
	ci.draw_circle(e + Vector2(-0.8, -0.9), 1.1, Color(1, 1, 1, 0.9))


# ---------------------------------------------------------------- bodies

static func _body_biped(ci: CanvasItem, c: Dictionary, shp: String, t: float, limb_part: bool) -> void:
	var sway := sin(t * 2.0) * 1.5
	var bulky := 1.25 if shp == "muscle" else 1.0
	limb(ci, [Vector2(-8, -50), Vector2(-12, -26), Vector2(-14, 0)], 7, 6, c.far, c.line)
	limb(ci, [Vector2(-18, -92), Vector2(-26, -74), Vector2(-24 + sway, -56)], 6 * bulky, 5, c.far, c.line)
	var torso: PackedVector2Array
	if shp == "segmented":
		torso = ellipse(Vector2(0, -84), 18, 16)
		shaded(ci, ellipse(Vector2(0, -60), 15, 13), c.base, c.line)
	elif shp == "faceted":
		torso = PackedVector2Array([Vector2(0, -102), Vector2(22, -84), Vector2(14, -52), Vector2(-14, -52), Vector2(-22, -84)])
	else:
		torso = capsule(Vector2(0, -56), Vector2(0, -92), 16 * bulky, 20 * bulky)
	shaded(ci, torso, c.base, c.line)
	limb(ci, [Vector2(8, -50), Vector2(12, -26), Vector2(14, 0)], 7.5, 6.5, c.base, c.line)
	shaded(ci, ellipse(Vector2(2, -114), 14, 15), c.belly, c.line)
	if not limb_part:
		limb(ci, [Vector2(18, -92), Vector2(26, -74), Vector2(28 - sway, -56)], 6.5 * bulky, 5.5, c.base, c.line)
		ci.draw_circle(Vector2(28 - sway, -55), 5.5, c.belly)
	else:
		limb(ci, [Vector2(18, -92), Vector2(25, -76)], 6.5 * bulky, 6.0, c.base, c.line)


static func _body_hexapod(ci: CanvasItem, c: Dictionary, shp: String, t: float) -> void:
	var step := sin(t * 6.0) * 2.0
	for i in 3:
		var x := -10.0 + i * 14.0
		limb(ci, [Vector2(x, -36), Vector2(x - 8, -52), Vector2(x - 14 - step, 0)], 3.2, 2.0, c.far, c.line)
	shaded(ci, ellipse(Vector2(-30, -38), 28, 20, 28, -0.15), c.base, c.line)
	for i in 3:
		ci.draw_arc(Vector2(-30, -38), 12.0 + i * 6.0, -1.9, -1.1, 6, c.dark, 2.0, true)
	shaded(ci, ellipse(Vector2(2, -44), 16, 14), c.base.lightened(0.05), c.line)
	shaded(ci, ellipse(Vector2(30, -50), 13, 11), c.belly, c.line)
	ci.draw_polyline(PackedVector2Array([Vector2(36, -58), Vector2(46, -78), Vector2(56, -82)]), c.line, 2.0, true)
	ci.draw_polyline(PackedVector2Array([Vector2(32, -60), Vector2(36, -82), Vector2(44, -90)]), c.line, 2.0, true)
	for i in 3:
		var x := -6.0 + i * 14.0
		limb(ci, [Vector2(x, -34), Vector2(x + 10, -50), Vector2(x + 16 + step, 0)], 3.6, 2.2, c.base, c.line)


static func _body_cluster(ci: CanvasItem, c: Dictionary, _shp: String, t: float) -> void:
	var pulse := 1.0 + sin(t * 1.6) * 0.03
	shaded(ci, blob(Vector2(-22, -18), 13, 0.12, 2.0), c.far, c.line)
	shaded(ci, capsule(Vector2(0, -4), Vector2(0, -60), 22, 16), c.belly, c.line)
	var cap := PackedVector2Array()
	for i in 21:
		var a := PI + PI * i / 20.0
		cap.append(Vector2(cos(a) * 44 * pulse, -66 + sin(a) * 32 * pulse))
	cap.append(Vector2(34, -60))
	cap.append(Vector2(-34, -60))
	shaded(ci, cap, c.base, c.line)
	for i in 5:
		var p := Vector2(-28 + i * 14, -78 - (i % 2) * 10)
		ci.draw_circle(p, 4.0 + (i % 3), c.accent.lerp(c.belly, 0.4))
	for i in 7:
		var x := -26.0 + i * 8.7
		ci.draw_line(Vector2(x, -61), Vector2(x * 0.7, -54), c.dark, 1.6, true)


static func _body_quadruped(ci: CanvasItem, c: Dictionary, _shp: String, t: float) -> void:
	var gait := sin(t * 5.0) * 2.0
	limb(ci, [Vector2(-26, -40), Vector2(-30, -20), Vector2(-28 + gait, 0)], 8, 6, c.far, c.line)
	limb(ci, [Vector2(20, -40), Vector2(24, -20), Vector2(22 - gait, 0)], 7.5, 6, c.far, c.line)
	var tail := PackedVector2Array([Vector2(-38, -52), Vector2(-56, -62 + sin(t * 3.0) * 4), Vector2(-66, -50)])
	ci.draw_polyline(tail, c.line, 9.0, true)
	ci.draw_polyline(tail, c.base, 5.5, true)
	shaded(ci, ellipse(Vector2(-2, -48), 42, 22), c.base, c.line)
	shaded(ci, capsule(Vector2(28, -54), Vector2(42, -68), 14, 13), c.base, c.line)
	var head := PackedVector2Array([Vector2(36, -80), Vector2(54, -80), Vector2(70, -66), Vector2(66, -58), Vector2(40, -56)])
	shaded(ci, head, c.belly, c.line)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(38, -78), Vector2(42, -94), Vector2(48, -79)]), c.dark)
	ci.draw_circle(Vector2(68, -63), 2.4, Color(0.1, 0.07, 0.06))
	limb(ci, [Vector2(-18, -38), Vector2(-20, -18), Vector2(-18 - gait, 0)], 8.5, 6.5, c.base, c.line)
	limb(ci, [Vector2(28, -38), Vector2(32, -18), Vector2(30 + gait, 0)], 8, 6.5, c.base, c.line)


static func _body_construct(ci: CanvasItem, c: Dictionary, t: float) -> void:
	var hover := sin(t * 2.2) * 3.0
	var glass: Color = c.base
	glass.a = 0.88
	shape(ci, ngon(Vector2(0, -14), 14, 4, PI / 4, 0.5), c.far, c.line)
	shape(ci, PackedVector2Array([Vector2(-26, -86 + hover), Vector2(-40, -70 + hover), Vector2(-30, -56 + hover)]), c.far, c.line)
	shaded(ci, PackedVector2Array([Vector2(0, -110 + hover), Vector2(26, -86 + hover), Vector2(16, -44 + hover),
		Vector2(0, -34 + hover), Vector2(-16, -44 + hover), Vector2(-26, -86 + hover)]), glass, c.line)
	ci.draw_polyline(PackedVector2Array([Vector2(0, -110 + hover), Vector2(0, -34 + hover)]), c.accent, 1.5, true)
	ci.draw_polyline(PackedVector2Array([Vector2(-26, -86 + hover), Vector2(0, -70 + hover), Vector2(26, -86 + hover)]), c.accent, 1.5, true)
	shaded(ci, ngon(Vector2(0, -122 + hover), 13, 6, 0.0, 1.1), c.belly, c.line)
	shape(ci, PackedVector2Array([Vector2(26, -86 + hover), Vector2(44, -70 + hover), Vector2(34, -54 + hover)]), glass, c.line)


static func _body_floater(ci: CanvasItem, c: Dictionary, t: float) -> void:
	var w := sin(t * 2.0)
	var robe := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		robe.append(Vector2(cos(a) * 24, -100 + sin(a) * 24))
	robe.append(Vector2(26, -62))
	robe.append(Vector2(18 + w * 4, -34))
	robe.append(Vector2(6 + w * 8, -14))
	robe.append(Vector2(-4 + w * 10, -6))
	robe.append(Vector2(-8 + w * 6, -26))
	robe.append(Vector2(-22, -54))
	var fill: Color = c.base
	fill.a = 0.82
	shaded(ci, robe, fill, c.line)
	shape(ci, ellipse(Vector2(4, -104), 15, 13), c.dark.darkened(0.3), c.line, 1.5)


# ---------------------------------------------------------------- parts

static func _draw_parts(ci: CanvasItem, parts: Array, slot: String, s: Dictionary, vg: Dictionary,
		races: Dictionary, t: float, skip: Dictionary = {}) -> void:
	for i in parts.size():
		var p: Dictionary = parts[i]
		if p.slot != slot or skip.has(i):
			continue
		var k := 1.0 if p.get("prominent", true) else 0.65
		var pc := part_colors(p, vg, races)
		var anchor: Vector2 = s.get(slot if slot != "skin" else "torso", Vector2.ZERO)
		_draw_part(ci, p, anchor, k, pc, s, vg.body_plan, t)


static func _draw_part(ci: CanvasItem, p: Dictionary, at: Vector2, k: float, pc: Dictionary,
		s: Dictionary, plan: String, t: float) -> void:
	var fill: Color = pc.fill
	var line: Color = pc.line
	var glow: Color = pc.glow
	var shp: String = p.shape
	match str(p.kind):
		"eye_compound":
			var e: Vector2 = s.eye
			shaded(ci, ellipse(e, 8 * k, 6.5 * k), Color(0.32, 0.06, 0.1), line, 1.8)
			for i in 6:
				ci.draw_circle(e + Vector2(cos(i * 1.05) * 4 * k, sin(i * 1.05) * 3 * k), 1.6 * k, glow.lerp(Color.WHITE, 0.3))
		"prism":
			var e2: Vector2 = s.eye + Vector2(0, -6)
			shaded(ci, PackedVector2Array([e2 + Vector2(0, -14) * k, e2 + Vector2(8, 4) * k, e2 + Vector2(-8, 4) * k]),
				Color(0.75, 0.92, 1.0, 0.9), line, 1.8)
			ci.draw_circle(e2, 2.5 * k, glow)
		"crest":
			var h: Vector2 = s.head + Vector2(-4, -s.head_r + 2)
			for i in 3:
				var base_p := h + Vector2(-8 + i * 7, 0) * k
				shape(ci, PackedVector2Array([base_p + Vector2(-4, 2) * k, base_p + Vector2(-6 + i * 2, -18 - i * 3) * k,
					base_p + Vector2(5, 2) * k]), fill, line, 1.8)
		"mandible":
			var m: Vector2 = s.head + Vector2(s.head_r - 2, 6)
			for sgn: float in [-1.0, 1.0]:
				shape(ci, PackedVector2Array([m + Vector2(0, sgn * 2) * k, m + Vector2(14, sgn * 6) * k,
					m + Vector2(18, sgn * 1) * k, m + Vector2(8, sgn * 1) * k]), pc.dark.lightened(0.2), line, 1.8)
		"fang":
			var f: Vector2 = s.eye + Vector2(4, 10)
			for dx: float in [0.0, 6.0]:
				shape(ci, PackedVector2Array([f + Vector2(dx, 0) * k, f + Vector2(dx + 4, 0) * k, f + Vector2(dx + 2, 9) * k]),
					Color(0.96, 0.93, 0.84), line, 1.4)
		"halo":
			var hc := glow
			hc.a = 0.75
			ci.draw_arc(s.head + Vector2(0, -s.head_r - 10), 14 * k, 0, TAU, 32, hc, 3.0, true)
			ci.draw_arc(s.head + Vector2(0, -s.head_r - 10), 9 * k, 0, TAU, 24, Color(hc, 0.35), 2.0, true)
		"sash":
			var c0: Vector2 = s.torso
			shape(ci, PackedVector2Array([c0 + Vector2(-16, -16), c0 + Vector2(-10, -20), c0 + Vector2(16, 14), c0 + Vector2(10, 18)]),
				Color(0.62, 0.16, 0.14), line, 1.6)
		"plating":
			var c1: Vector2 = s.torso
			for i in 3:
				var y := -14.0 + i * 11.0
				shaded(ci, PackedVector2Array([c1 + Vector2(-13, y) * k, c1 + Vector2(13, y) * k, c1 + Vector2(11, y + 9) * k,
					c1 + Vector2(-11, y + 9) * k]), Color(0.62, 0.66, 0.72), line, 1.6)
				ci.draw_circle(c1 + Vector2(9, y + 4.5) * k, 1.3, Color(0.9, 0.9, 0.95))
		"shell_plate":
			var c2: Vector2 = s.back + Vector2(4, 10)
			for i in 4:
				var pt := c2 + Vector2(-18 + i * 11, -abs(i - 1.5) * 3) * k
				shaded(ci, ellipse(pt, 10 * k, 7 * k, 16, -0.4), pc.dark.lightened(0.15), line, 1.6)
		"sac", "volatile_sac":
			var pulse := 1.0 + sin(t * (5.0 if p.kind == "volatile_sac" else 2.5)) * 0.08
			var sc := glow
			sc.a = 0.85
			shaded(ci, blob(at + Vector2(-2, 2), 9 * k * pulse, 0.08, 4.0), sc, line, 1.8)
			ci.draw_arc(at + Vector2(-2, 2), 5 * k, 0.5, 2.6, 8, glow.darkened(0.4), 1.4, true)
		"satchel":
			shaded(ci, PackedVector2Array([at + Vector2(-12, -4), at + Vector2(4, -4), at + Vector2(5, 10), at + Vector2(-11, 10)]),
				Color(0.45, 0.32, 0.2), line, 1.6)
			ci.draw_line(at + Vector2(-4, -4), at + Vector2(10, -22), Color(0.3, 0.2, 0.12), 2.5, true)
			ci.draw_line(at + Vector2(-6, 3), at + Vector2(0, 3), Color(0.9, 0.2, 0.2), 2.5)
			ci.draw_line(at + Vector2(-3, 0), at + Vector2(-3, 6), Color(0.9, 0.2, 0.2), 2.5)
		"core_gem":
			var gc := glow.lerp(Color.WHITE, 0.2)
			shaded(ci, ngon(at, 8 * k, 6, t * 0.5), gc, line, 1.6)
			ci.draw_circle(at, 3 * k, Color.WHITE)
		"bloom":
			for i in 6:
				var a := TAU * i / 6.0 + t * 0.2
				shaded(ci, ellipse(at + Vector2(cos(a), sin(a)) * 7 * k, 6 * k, 3.5 * k, 12, a), fill.lightened(0.15), line, 1.3)
			ci.draw_circle(at, 4 * k, glow)
		"egg_sac":
			for i in 4:
				var ep := at + Vector2(-16 + i * 7, -2 - (i % 2) * 7) * k
				shaded(ci, ellipse(ep, 6.5 * k, 8 * k), Color(0.92, 0.86, 0.66, 0.92), line, 1.5)
		"spore_cap":
			for i in 3:
				var cp := at + Vector2(-10 + i * 12, -(i % 2) * 10 - 4) * k
				ci.draw_line(cp, cp + Vector2(0, 10) * k, Color(0.85, 0.82, 0.7), 4.0 * k, true)
				var cap := PackedVector2Array()
				for j in 11:
					var a := PI + PI * j / 10.0
					cap.append(cp + Vector2(cos(a) * 9, sin(a) * 7) * k)
				shaded(ci, cap, fill, line, 1.6)
				ci.draw_circle(cp + Vector2(-3, -3) * k, 1.6 * k, Color(1, 1, 1, 0.8))
		"crystal_cluster":
			var cc := Color(0.62, 0.86, 1.0, 0.9)
			for i in 4:
				var bp := at + Vector2(-14 + i * 9, 6) * k
				var h := (16.0 + (i % 2) * 10.0) * k
				shaded(ci, PackedVector2Array([bp + Vector2(-5, 0) * k, bp + Vector2(-1, -h), bp + Vector2(5, 0) * k]), cc, line, 1.5)
		"banner":
			var pole := at + Vector2(-10, 0)
			ci.draw_line(pole + Vector2(0, 20), pole + Vector2(0, -58), Color(0.35, 0.25, 0.15), 3.0, true)
			var wave := sin(t * 3.0) * 3.0
			shape(ci, PackedVector2Array([pole + Vector2(0, -58), pole + Vector2(-26, -54 + wave), pole + Vector2(-24, -38 + wave),
				pole + Vector2(0, -40)]), Color(0.66, 0.18, 0.16), line, 1.6)
		"fur_mane":
			var base_p: Vector2 = s.back
			for i in 5:
				var fp := base_p + Vector2(-16 + i * 8, 4 - abs(i - 2) * 2)
				shape(ci, PackedVector2Array([fp + Vector2(-5, 4), fp + Vector2(-2, -14 - (i % 2) * 5), fp + Vector2(5, 4)]),
					pc.dark.lightened(0.25), line, 1.4)
		"ether_veil":
			var vc := glow
			vc.a = 0.32
			var veil := PackedVector2Array()
			for i in 9:
				var y := -40.0 + i * 9.0
				veil.append(at + Vector2(-20 - sin(t * 2.0 + i * 0.7) * 6 - i * 2, y))
			veil.append(at + Vector2(0, 40))
			veil.append(at + Vector2(6, -40))
			ci.draw_colored_polygon(veil, vc)
		"mycelium_web":
			var c3: Vector2 = s.torso
			var wc := Color(0.95, 0.95, 0.88, 0.85)
			for i in 5:
				var a := -2.6 + i * 0.9
				var p0 := c3 + Vector2(cos(a), sin(a)) * 4
				var p1 := c3 + Vector2(cos(a + 0.3), sin(a + 0.3)) * 16
				var p2 := c3 + Vector2(cos(a - 0.2), sin(a - 0.2)) * 26
				ci.draw_polyline(PackedVector2Array([p0, p1, p2]), wc, 1.3, true)
		"spear":
			var hand: Vector2 = s.limb
			_arm(ci, s, plan, hand, pc)
			ci.draw_line(hand + Vector2(-26, 22), hand + Vector2(34, -36), Color(0.42, 0.3, 0.18), 3.0, true)
			shape(ci, PackedVector2Array([hand + Vector2(30, -32), hand + Vector2(44, -48), hand + Vector2(36, -28)]),
				Color(0.8, 0.82, 0.86), line, 1.4)
		"claw":
			var hp2: Vector2 = s.limb
			_arm(ci, s, plan, hp2, pc)
			for i in 3:
				var cp2 := hp2 + Vector2(2 + i * 4, 2)
				shape(ci, PackedVector2Array([cp2, cp2 + Vector2(8, 4 + i), cp2 + Vector2(3, 1)]), Color(0.95, 0.92, 0.82), line, 1.2)
		"spray_nozzle":
			var hp3: Vector2 = s.limb
			_arm(ci, s, plan, hp3, pc)
			shaded(ci, capsule(hp3, hp3 + Vector2(14, -4) * k, 5 * k, 3.5 * k), pc.dark.lightened(0.2), line)
			var drip := fmod(t * 1.5, 1.0)
			ci.draw_circle(hp3 + Vector2(16, -2 + drip * 14) * k, 2.2, glow)
		"tendril":
			var hp4: Vector2 = s.limb + Vector2(-8, -10)
			var pts: Array = []
			for i in 6:
				pts.append(hp4 + Vector2(i * 6.0, i * 3.0 + sin(t * 2.5 + i * 0.9) * 4.0) * k)
			limb(ci, pts, 5.5 * k, 1.5, fill, line)
		"soul_claw":
			var hp5: Vector2 = s.limb
			var gc2 := glow
			gc2.a = 0.8
			for i in 3:
				var a0 := hp5 + Vector2(-6, -6 + i * 4)
				ci.draw_polyline(PackedVector2Array([a0, a0 + Vector2(12, -2 + i * 3), a0 + Vector2(22, 2 + i * 5)]), gc2, 2.2, true)
		_:
			ci.draw_circle(at, 5 * k, fill)


## Stub arm used when a limb part replaces the default near arm (biped / construct / floater).
static func _arm(ci: CanvasItem, s: Dictionary, plan: String, hand: Vector2, pc: Dictionary) -> void:
	if plan in ["hexapod", "quadruped", "cluster"] or s.get("textured_body", false):
		return
	var shoulder: Vector2 = s.torso + Vector2(18, -14)
	limb(ci, [shoulder, hand + Vector2(-2, -12), hand], 6.0, 5.0, pc.fill, pc.line)
