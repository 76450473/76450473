extends Node2D
## Art QA scenes — screenshot ALL pages after every art import (references/art-pipeline.md §4–§5).
##   page 1 (art_gallery.tscn): bare body per body plan with socket markers + race showcases + all icons
##   page 2 (art_parts.tscn):   every one of the part kinds, each worn alone by a fitting creature
##   page 3 (art_images.tscn):  backgrounds, title, UI, card frame/back, boss and card illustrations
##   page 4 (art_enemies.tscn): villain bodies (enemies) bare + wearing genes, facing left like on the board
## Imported asset = drawn from art/; missing = procedural fallback or a dashed placeholder box.
## Fix misplaced parts via art/bodies/<plan>.json "sockets" or art/parts/<kind>.json "offset"/"scale_mult".

@export var page: int = 1

var db: GameData
var _boxes: Array = []  # [Rect2]


func _ready() -> void:
	db = Data.db
	ArtLibrary.clear()
	var entries := ArtManifest.build(db)
	var done := 0
	for e: Dictionary in entries:
		if ArtManifest.is_present(e):
			done += 1
	var titles := {1: "骨架 · 种族展示 · 图标", 2: "全部部件（每个部件单独装在一只生物身上）", 3: "背景 · 界面 · Boss · 卡图",
		4: "敌方反派（骨架 · 装上基因，朝左）"}
	_label(Vector2(24, 12), 22, "美术检查台 %d/4：%s　｜　已导入 %d / %d" % [page, titles.get(page, ""), done, entries.size()])
	_label(Vector2(24, 44), 13, "✓ = 用的是导入的图；（占位）= 程序画的占位。粉色十字 = 部件挂点。错位：调 art/bodies/<骨架>.json 的 sockets 或 art/parts/<部件>.json 的 offset / scale_mult / rotation")
	match page:
		2:
			_page_parts()
		3:
			_page_images(entries)
		4:
			_page_enemies()
		_:
			_page_bodies_icons(entries)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 900), Color("#15121b"))
	for r: Rect2 in _boxes:
		draw_rect(r, Color("#2a2533"))
		draw_rect(r, Color("#5a5068"), false, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_S:
		for c in get_children():
			if c is CreatureView:
				(c as CreatureView).show_sockets = not (c as CreatureView).show_sockets


# ---------------------------------------------------------------- page 1

func _page_bodies_icons(entries: Array) -> void:
	var col_w := 260.0
	var i := 0
	for plan: String in Defs.BODY_PLANS:
		var spec := {"template": _template_for(_race_for_plan(plan), ""), "genes": []}
		_creature(spec, Vector2(130 + i * col_w, 300), true, 1.15)
		var ok := not ArtLibrary.body(plan).is_empty()
		_label(Vector2(40 + i * col_w, 326), 14, "body_%s %s" % [plan, "✓" if ok else "（占位）"])
		i += 1
	i = 0
	for race: String in db.races:
		var spec := _showcase(race)
		_creature(spec, Vector2(130 + i * col_w, 590), false, 1.15)
		var n_tex := 0
		var n_all := 0
		for g: Dictionary in UnitBuilder.resolve_genes(spec, db):
			var kind: String = (g.get("visual", {}) as Dictionary).get("part", "none")
			if kind != "none":
				n_all += 1
				if not ArtLibrary.part(kind).is_empty():
					n_tex += 1
		_label(Vector2(40 + i * col_w, 616), 14, "%s展示 · 导入部件 %d/%d" % [db.races[race].name, n_tex, n_all])
		i += 1
	var ix := 0
	for e: Dictionary in entries:
		if e.category != "icon":
			continue
		var cell := Vector2(24 + (ix % 22) * 71, 668 + (ix / 22) * 112)
		var art := ArtLibrary.lookup(str(e.path).get_basename())
		if art.is_empty():
			_boxes.append(Rect2(cell, Vector2(48, 48)))
		else:
			var spr := Sprite2D.new()
			spr.texture = art.texture
			spr.position = cell + Vector2(24, 24)
			var tsz: Vector2 = (art.texture as Texture2D).get_size()
			spr.scale = Vector2.ONE * (44.0 / maxf(tsz.x, tsz.y))
			spr.modulate = Color("#e9dcc0")
			add_child(spr)
		var short_name: String = str(e.cn).get_slice("·", str(e.cn).get_slice_count("·") - 1)
		_label(cell + Vector2(-2, 50), 11, short_name + ("" if art.is_empty() else " ✓"))
		ix += 1


# ---------------------------------------------------------------- page 2

func _page_parts() -> void:
	var kinds: Array = []
	for k: String in Defs.PART_KINDS:
		if k != "none":
			kinds.append(k)
	var cols := 9
	for i in kinds.size():
		var kind: String = kinds[i]
		var spec := _spec_for_part(kind)
		var pos := Vector2(90 + (i % cols) * 172, 250 + (i / cols) * 230)
		if spec.is_empty():
			_boxes.append(Rect2(pos + Vector2(-50, -120), Vector2(100, 120)))
		else:
			_creature(spec, pos, true, 0.9)
		var ok := not ArtLibrary.part(kind).is_empty()
		_label(pos + Vector2(-78, 12), 13, "%s %s" % [kind, "✓" if ok else "（占位）"])


func _spec_for_part(kind: String) -> Dictionary:
	var ids: Array = db.genes.keys()
	ids.sort()
	for gid: String in ids:
		var g := db.get_gene(gid)
		if (g.get("visual", {}) as Dictionary).get("part", "none") != kind:
			continue
		var tpl := _template_for(g.race, g.slot)
		if tpl == "":
			tpl = _any_template_with_slot(g.slot)
		if tpl != "":
			return {"template": tpl, "genes": [gid]}
	return {}


# ---------------------------------------------------------------- page 3

func _page_images(entries: Array) -> void:
	var x := 24.0
	var y := 80.0
	var row_h := 0.0
	for e: Dictionary in entries:
		if not (e.category in ["background", "ui", "boss", "card_art"]):
			continue
		var size := Vector2(150, 210)
		match str(e.category):
			"background":
				size = Vector2(368, 207)
			"card_art":
				size = Vector2(200, 150)
			"boss":
				size = Vector2(220, 220)
			_:
				if str(e.id) == "title_art":
					size = Vector2(368, 207)
				elif str(e.id) == "ui_button":
					size = Vector2(240, 80)
				elif str(e.id) == "ui_panel":
					size = Vector2(160, 160)
		if x + size.x > 1580:
			x = 24.0
			y += row_h + 40
			row_h = 0.0
		var box := Rect2(Vector2(x, y), size)
		var art := ArtLibrary.lookup(str(e.path).get_basename())
		if art.is_empty():
			_boxes.append(box)
		else:
			var spr := Sprite2D.new()
			spr.texture = art.texture
			spr.centered = false
			var tsz: Vector2 = (art.texture as Texture2D).get_size()
			var k := minf(box.size.x / tsz.x, box.size.y / tsz.y)
			spr.scale = Vector2(k, k)
			spr.position = box.position + (box.size - tsz * k) / 2.0
			add_child(spr)
		_label(box.position + Vector2(0, box.size.y + 2), 12, "%s %s" % [e.cn, "✓" if not art.is_empty() else "（占位）"])
		x += size.x + 18
		row_h = maxf(row_h, size.y)


# ---------------------------------------------------------------- page 4

func _page_enemies() -> void:
	var col_w := 260.0
	var i := 0
	for plan: String in Defs.BODY_PLANS:
		var race := _race_for_plan(plan)
		var bare := {"template": _template_for(race, ""), "genes": [], "enemy": true}
		_creature(bare, Vector2(130 + i * col_w, 380), true, 1.0, -1)
		var ok := not ArtLibrary.lookup("res://art/bodies/%s_enemy" % plan).is_empty()
		var state := "✓" if ok else ("（暂用我方立绘）" if not ArtLibrary.body(plan).is_empty() else "（占位）")
		_label(Vector2(40 + i * col_w, 400), 14, "body_%s_enemy %s" % [plan, state])
		var armed := _showcase(race)
		armed["enemy"] = true
		_creature(armed, Vector2(130 + i * col_w, 780), false, 1.0, -1)
		_label(Vector2(40 + i * col_w, 800), 14, "敌方%s · 装上基因" % db.races[race].name)
		i += 1


# ---------------------------------------------------------------- helpers

func _creature(spec: Dictionary, pos: Vector2, sockets_on: bool, s: float, facing: int = 1) -> CreatureView:
	var view := CreatureView.new()
	view.position = pos
	add_child(view)
	view.setup(VisualGenome.build(spec, db), db.races, facing, s)
	view.show_sockets = sockets_on
	return view


func _race_for_plan(plan: String) -> String:
	for r: String in db.races:
		if db.races[r].get("body_plan", "") == plan:
			return r
	return "human"


## Recruitable template of `race` with the most slots (and having `slot`, if given).
func _template_for(race: String, slot: String) -> String:
	var best := ""
	var best_slots := -1
	for u: Dictionary in db.recruitable_units(race):
		var slots: Array = u.get("slots", [])
		if slot != "" and not slots.has(slot):
			continue
		if slots.size() > best_slots:
			best_slots = slots.size()
			best = u.id
	return best


func _any_template_with_slot(slot: String) -> String:
	for r: String in db.races:
		var t := _template_for(r, slot)
		if t != "":
			return t
	return ""


## Template with the most slots, wearing one gene of this race per slot (stability ignored).
func _showcase(race: String) -> Dictionary:
	var spec := {"template": _template_for(race, ""), "genes": []}
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
