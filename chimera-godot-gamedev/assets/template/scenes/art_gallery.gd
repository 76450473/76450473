extends Node2D
## Art QA scene — screenshot this after every art import (references/art-pipeline.md §5).
## Row 1: bare body of each body plan with socket markers (pink crosses = where parts attach).
## Row 2: one showcase creature per race wearing that race's parts.
## Bottom: every icon; right column: backgrounds / UI / boss / card art.
## Imported asset = drawn from art/, missing = procedural fallback or a dashed placeholder box.
## Fix misplaced parts via art/bodies/<plan>.json "sockets" or art/parts/<kind>.json "offset"/"scale_mult".

const BODY_Y := 300.0
const SHOW_Y := 590.0
const COL_W := 178.0

var db: GameData
var _boxes: Array = []  # [Rect2, label, present]


func _ready() -> void:
	db = Data.db
	ArtLibrary.clear()
	var entries := ArtManifest.build(db)
	var done := 0
	for e: Dictionary in entries:
		if ArtManifest.is_present(e):
			done += 1
	_label(Vector2(24, 12), 22, "美术资产检查台 · 已导入 %d / %d（缺失的用占位显示）" % [done, entries.size()])
	_label(Vector2(24, 44), 13, "粉色十字 = 部件挂点。部件位置不对：调 art/bodies/<骨架>.json 的 sockets，或 art/parts/<部件>.json 的 offset / scale_mult")
	var i := 0
	for plan: String in Defs.BODY_PLANS:
		var race := _race_for_plan(plan)
		var spec := {"template": _template_for(race), "genes": []}
		var v := _creature(spec, Vector2(100 + i * COL_W, BODY_Y), true)
		var ok := not ArtLibrary.body(plan).is_empty()
		_label(Vector2(30 + i * COL_W, BODY_Y + 26), 13, "body_%s %s" % [plan, "✓" if ok else "（占位）"])
		v.name = "body_" + plan
		i += 1
	i = 0
	for race: String in db.races:
		var spec := _showcase(race)
		_creature(spec, Vector2(100 + i * COL_W, SHOW_Y), false)
		var n_tex := 0
		var n_all := 0
		for g: Dictionary in UnitBuilder.resolve_genes(spec, db):
			var kind: String = (g.get("visual", {}) as Dictionary).get("part", "none")
			if kind != "none":
				n_all += 1
				if not ArtLibrary.part(kind).is_empty():
					n_tex += 1
		_label(Vector2(30 + i * COL_W, SHOW_Y + 26), 13, "%s 部件 %d/%d" % [db.races[race].name, n_tex, n_all])
		i += 1
	# icons
	var ix := 0
	for e: Dictionary in entries:
		if e.category != "icon":
			continue
		var cell := Vector2(24 + (ix % 18) * 60, 660 + (ix / 18) * 78)
		var art := ArtLibrary.lookup(str(e.path).get_basename())
		if art.is_empty():
			_boxes.append([Rect2(cell, Vector2(44, 44)), "", false])
		else:
			var spr := Sprite2D.new()
			spr.texture = art.texture
			spr.position = cell + Vector2(22, 22)
			var tsz: Vector2 = (art.texture as Texture2D).get_size()
			spr.scale = Vector2.ONE * (40.0 / maxf(tsz.x, tsz.y))
			spr.modulate = Color("#e9dcc0")
			add_child(spr)
		_label(cell + Vector2(-2, 46), 10, str(e.cn).get_slice("·", e.cn.get_slice_count("·") - 1))
		ix += 1
	# big images
	var by := 70.0
	for e: Dictionary in entries:
		if not (e.category in ["background", "ui", "boss", "card_art"]):
			continue
		if by > 860:
			break
		var box := Rect2(Vector2(1110, by), Vector2(150, 84))
		if e.category == "background":
			box = Rect2(Vector2(1110, by), Vector2(224, 126))
		var art := ArtLibrary.lookup(str(e.path).get_basename())
		if art.is_empty():
			_boxes.append([box, "", false])
		else:
			var spr := Sprite2D.new()
			spr.texture = art.texture
			spr.centered = false
			spr.position = box.position
			var tsz: Vector2 = (art.texture as Texture2D).get_size()
			var k := minf(box.size.x / tsz.x, box.size.y / tsz.y)
			spr.scale = Vector2(k, k)
			add_child(spr)
		_label(box.position + Vector2(box.size.x + 8, 0), 11, "%s\n%s" % [e.id, e.cn])
		by += box.size.y + 10
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 900), Color("#15121b"))
	draw_line(Vector2(0, BODY_Y + 4), Vector2(1090, BODY_Y + 4), Color("#3a3346"), 1.0)
	draw_line(Vector2(0, SHOW_Y + 4), Vector2(1090, SHOW_Y + 4), Color("#3a3346"), 1.0)
	for b: Array in _boxes:
		var r: Rect2 = b[0]
		draw_rect(r, Color("#2a2533"))
		draw_rect(r, Color("#5a5068"), false, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_S:
		for c in get_children():
			if c is CreatureView:
				(c as CreatureView).show_sockets = not (c as CreatureView).show_sockets


func _creature(spec: Dictionary, pos: Vector2, sockets_on: bool) -> CreatureView:
	var view := CreatureView.new()
	view.position = pos
	add_child(view)
	view.setup(VisualGenome.build(spec, db), db.races, 1, 1.15)
	view.show_sockets = sockets_on
	return view


func _race_for_plan(plan: String) -> String:
	for r: String in db.races:
		if db.races[r].get("body_plan", "") == plan:
			return r
	return "human"


func _template_for(race: String) -> String:
	var best := ""
	var best_slots := -1
	for u: Dictionary in db.recruitable_units(race):
		if (u.get("slots", []) as Array).size() > best_slots:
			best_slots = (u.get("slots", []) as Array).size()
			best = u.id
	return best


## Template with the most slots, wearing one gene of this race per slot (stability ignored).
func _showcase(race: String) -> Dictionary:
	var tpl := _template_for(race)
	var spec := {"template": tpl, "genes": []}
	var ids: Array = []
	for g: Dictionary in db.genes_of_race(race):
		ids.append(g.id)
	ids.sort()
	for gid: String in ids:
		var g := db.get_gene(gid)
		if (g.get("visual", {}) as Dictionary).get("part", "none") != "none" and UnitBuilder.can_attach(spec, g, db):
			spec.genes.append(gid)
	return spec


func _label(pos: Vector2, size: int, text: String) -> Label:
	var l := Label.new()
	l.position = pos
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#d8cfbd"))
	add_child(l)
	return l
