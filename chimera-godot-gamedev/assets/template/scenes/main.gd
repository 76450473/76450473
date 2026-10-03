extends Node2D
## M0 demo scene — "基因实验室". Proves the whole pipeline end to end:
## data -> genome -> fusion -> VisualGenome -> CreatureView, plus a headless CombatSim run.
## Keys: R = random generated enemies   F = random fusion   B = re-run battle   D = demo set
## Replace with the real title/run flow in milestone M1 (see references/roadmap.md).

const SPACING := 250.0
const ROW_Y := 520.0
const SPECIMEN_SCALE := 1.6

var db: GameData
var rng := RandomNumberGenerator.new()
var _views: Array[Node] = []
var _title: Label
var _info: Label


func _ready() -> void:
	db = Data.db
	rng.seed = 20261003
	_title = _label(Vector2(40, 24), 30, Color("#efe6d2"))
	_title.text = "奇美拉纪元 · 基因实验室（原型）"
	var hint := _label(Vector2(40, 70), 16, Color("#a99f8f"))
	hint.text = "D 演示组  R 随机敌族  F 随机融合  B 重跑战斗   ——  同一套基因语言驱动 外观 / 战斗 / 敌人生成"
	_info = _label(Vector2(40, 776), 17, Color("#d8cfbd"))
	_info.size = Vector2(1520, 120)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_show(_demo_specs())
	_battle()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 900), Color("#14111a"))
	draw_rect(Rect2(0, ROW_Y + 4, 1600, 230), Color("#1d1924"))
	draw_line(Vector2(0, ROW_Y + 4), Vector2(1600, ROW_Y + 4), Color("#3a3346"), 2.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match (event as InputEventKey).keycode:
			KEY_D:
				_show(_demo_specs())
			KEY_R:
				_show(_random_specs())
			KEY_F:
				_random_fusion()
			KEY_B:
				_battle()


func _demo_specs() -> Array:
	var spray_venom := GeneFusion.fuse(db.get_gene("insect_spray"), db.get_gene("insect_venom_gland"), db)
	return [
		{"template": "human_militia", "genes": ["human_plating", "human_spear"]},
		{"template": "human_militia", "genes": ["insect_compound_eye", "human_plating"]},
		{"template": "human_militia", "genes": [spray_venom, "insect_compound_eye", "insect_carapace"]},
		{"template": "beast_hunter", "genes": ["crystal_refraction", "crystal_lattice"]},
		{"template": "fungal_mother", "genes": ["fungal_spore_sac", "fungal_plague_heart", "fungal_mycelium_net"]},
		{"template": "wraith_wisp", "genes": ["wraith_dread", "wraith_ether_body", "wraith_soul_siphon"]},
	]


func _random_specs() -> Array:
	var out: Array = []
	var race_ids: Array = db.races.keys()
	for i in 6:
		var race: String = race_ids[rng.randi_range(0, race_ids.size() - 1)]
		var team := EnemyFactory.generate(db, rng, race, 2, rng.randf() < 0.5)
		if not team.is_empty():
			out.append(team[0])
	return out


func _show(specs: Array) -> void:
	for v in _views:
		v.queue_free()
	_views.clear()
	for i in specs.size():
		var spec: Dictionary = specs[i]
		var vg := VisualGenome.build(spec, db)
		var view := CreatureView.new()
		view.position = Vector2(170 + i * SPACING, ROW_Y)
		add_child(view)
		view.setup(vg, db.races, 1, SPECIMEN_SCALE)
		_views.append(view)
		var info := UnitBuilder.genome_info(spec, db)
		var names: PackedStringArray = []
		for g: Dictionary in UnitBuilder.resolve_genes(spec, db):
			names.append(str(g.get("name", "?")))
		var label := _label(Vector2(170 + i * SPACING - 110, ROW_Y + 22), 20, Color("#f1e7d0"))
		label.size = Vector2(220, 30)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.text = vg.name
		_views.append(label)
		var sub := _label(Vector2(170 + i * SPACING - 110, ROW_Y + 54), 14, Color("#b3a994"))
		sub.size = Vector2(220, 120)
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var status := "  纯血共鸣" if info.pure else ("  过载！突变风险" if info.overload > 0 else "")
		sub.text = "%s\n%s\n稳定度 %d/%d%s" % [VisualGenome.lineage_label(vg, db), " · ".join(names),
			info.load, info.capacity, status]
		_views.append(sub)


func _random_fusion() -> void:
	var ids: Array = db.genes.keys()
	for attempt in 50:
		var a := db.get_gene(ids[rng.randi_range(0, ids.size() - 1)])
		var b := db.get_gene(ids[rng.randi_range(0, ids.size() - 1)])
		if not GeneFusion.can_fuse(a, b):
			continue
		var biome: Dictionary = db.biomes.values()[rng.randi_range(0, db.biomes.size() - 1)]
		var g := GeneFusion.fuse(a, b, db, biome)
		_info.text = "融合（%s）：形「%s」 × 质「%s」 → 【%s】%s\n%s" % [biome.name, a.name, b.name, g.name,
			"  ★隐藏配方" if g.has("recipe") else "", GeneMath.describe_gene(g, db.unit_names())]
		var hosts: Array = []
		for tpl: String in ["human_militia", "human_scout", "insect_drone", "fungal_mother"]:
			if UnitBuilder.can_attach({"template": tpl, "genes": []}, g, db):
				hosts.append({"template": tpl, "genes": [g]})
		_show(hosts)
		return


func _battle() -> void:
	var team: Array = _demo_specs().slice(0, 3)
	for i in team.size():
		team[i]["lane"] = i
		team[i]["row"] = 0
	var biome := db.biomes.get("swamp", {}) as Dictionary
	var enemies := EnemyFactory.generate(db, rng, "fungal", 2, true, biome)
	var sim := CombatSim.new(db, rng, biome.get("rules", {}))
	sim.add_team(team, 0)
	sim.add_team(enemies, 1)
	var result := sim.run_auto()
	var who := {0: "玩家胜利", 1: "敌方胜利", -1: "平局"}
	_info.text = "演示战斗（%s · 精英菌族 %d 单位）：%s，%d 回合，%d 条事件%s\n战斗是纯数据模拟（CombatSim），同一份事件日志之后交给战斗表现层逐条播放。" % [
		biome.get("name", "?"), enemies.size(), who.get(result, "?"), sim.round_num, sim.events.size(),
		"（触发上限！）" if sim.hit_trigger_cap else ""]


func _label(pos: Vector2, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	return l
