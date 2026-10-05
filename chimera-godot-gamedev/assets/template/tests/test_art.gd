extends TestCase
## Art pipeline: manifest coverage, importer image processing, library fallback.


func test_manifest_covers_all_content() -> void:
	var entries := ArtManifest.build(db)
	var ids := ArtManifest.by_id(entries)
	check_eq(ids.size(), entries.size(), "asset ids unique")
	for kind: String in Defs.PART_KINDS:
		if kind != "none":
			check(ids.has("part_" + kind), "part_%s listed" % kind)
	for plan: String in Defs.BODY_PLANS:
		check(ids.has("body_" + plan), "body_%s listed" % plan)
	for b: String in db.biomes:
		check(ids.has("bg_" + b), "bg_%s listed" % b)
	for st: String in Defs.STATUSES:
		check(ids.has("icon_status_" + st), "status icon %s listed" % st)
	for e: Dictionary in entries:
		check(str(e.prompt).length() > 80, "%s has a real prompt" % e.id)
		check(str(e.path).begins_with("res://art/"), "%s path under art/" % e.id)
		check(int(e.priority) >= 1 and int(e.priority) <= 3, "%s priority" % e.id)


func test_part_prompts_carry_race_style_and_accent() -> void:
	var e: Dictionary = ArtManifest.by_id(ArtManifest.build(db))["part_eye_compound"]
	check(str(e.prompt).contains("chitin"), "insect surface materials in prompt")
	check(str(e.prompt).contains("Glowing details:"), "accent clause present")
	check_eq(e.mode, "cutout", "parts are full-colour illustrated accessories")
	check_eq(int(e.priority), 1, "playable-race part is P1")


func test_markdown_lists_every_entry() -> void:
	var entries := ArtManifest.build(db)
	var md := ArtManifest.to_markdown(entries, "t", "i")
	for e: Dictionary in entries:
		check(md.contains("`%s`" % e.id), "%s in markdown" % e.id)


func _synthetic(bg: Color, with_glow: bool) -> Image:
	# 200x200: flat background, dark-outlined gray disc, optional green glow spot
	var img := Image.create(200, 200, false, Image.FORMAT_RGBA8)
	img.fill(bg)
	for y in 200:
		for x in 200:
			var d := Vector2(x - 100, y - 110).length()
			if d < 60:
				img.set_pixel(x, y, Color(0.06, 0.06, 0.06))
			if d < 54:
				img.set_pixel(x, y, Color(0.62, 0.6, 0.58))
			if d < 20 and with_glow:
				img.set_pixel(x, y, Color(0.3, 0.95, 0.2))
			if d < 10 and not with_glow:
				img.set_pixel(x, y, Color(1, 1, 1))  # enclosed white highlight must survive
	return img


func test_importer_palette_mode() -> void:
	var entry := {"mode": "palette", "canvas": [100, 100], "fit": "fit", "anchor": "bottom_center"}
	var res := ArtImporter.process(_synthetic(Color.WHITE, true), entry)
	var img: Image = res.image
	check(img.get_width() <= 100 and img.get_height() <= 100, "fits canvas")
	check(img.get_width() >= 95 or img.get_height() >= 95, "trimmed then scaled up to canvas")
	check(img.get_pixel(0, 0).a < 0.05, "background corner transparent")
	var c := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
	check(c.a > 0.95, "center opaque")
	check(c.g - c.r > 0.3, "saturated glow kept as accent")
	var body := img.get_pixel(img.get_width() / 2, img.get_height() / 5)
	check(absf(body.r - body.g) < 0.02 and absf(body.g - body.b) < 0.02, "body desaturated to gray")
	var pivot: Vector2 = res.pivot
	check_eq(pivot, Vector2(img.get_width() / 2.0, img.get_height()), "bottom_center pivot")
	check((res.warnings as PackedStringArray).is_empty(), "no warnings: %s" % [res.warnings])


func test_importer_keeps_enclosed_highlight() -> void:
	var res := ArtImporter.process(_synthetic(Color.WHITE, false), {"mode": "palette", "canvas": [120, 120]})
	var img: Image = res.image
	var c := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
	check(c.a > 0.95 and c.r > 0.9, "white highlight inside the outline is not removed")


func test_importer_mono_icon() -> void:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)
	img.fill_rect(Rect2i(20, 20, 24, 24), Color.WHITE)
	var res := ArtImporter.process(img, {"mode": "mono", "canvas": [32, 32]})
	var out: Image = res.image
	check_eq(out.get_size(), Vector2i(32, 32), "trimmed square scaled to canvas")
	check(out.get_pixel(16, 16).a > 0.95 and out.get_pixel(16, 16).r > 0.99, "white opaque symbol")


func test_importer_warns_on_colored_palette_art() -> void:
	var img := Image.create(80, 80, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	img.fill_rect(Rect2i(10, 10, 60, 60), Color(0.05, 0.05, 0.05))
	img.fill_rect(Rect2i(14, 14, 52, 52), Color(0.8, 0.2, 0.2))
	var res := ArtImporter.process(img, {"mode": "palette", "canvas": [80, 80]})
	check(not (res.warnings as PackedStringArray).is_empty(), "colored art in palette mode is flagged")


func test_importer_cover_crops_background() -> void:
	var img := Image.create(400, 100, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.3, 0.4))
	var res := ArtImporter.process(img, {"mode": "color", "canvas": [160, 90], "fit": "cover"})
	check_eq((res.image as Image).get_size(), Vector2i(160, 90), "cover = exact canvas")


func test_library_missing_asset_falls_back() -> void:
	ArtLibrary.clear()
	check(ArtLibrary.part("definitely_not_a_part").is_empty(), "missing part -> {}")
	ArtLibrary.enabled = false
	check(ArtLibrary.body("biped").is_empty(), "disabled library -> {}")
	ArtLibrary.enabled = true


func test_manifest_mode_override() -> void:
	var saved: Dictionary = db.art.duplicate(true)
	db.art.parts.spear["mode"] = "cutout"
	var e: Dictionary = ArtManifest.by_id(ArtManifest.build(db))["part_spear"]
	check_eq(e.mode, "cutout", "per-part mode override respected")
	db.art = saved


func test_importer_matches_messy_file_names() -> void:
	var script: GDScript = load("res://tools/import_art.gd")
	var tool: Object = script.new()
	var entries := ArtManifest.by_id(ArtManifest.build(db))
	for raw: String in ["part_sac.png", "part_sac.png.png", "sac (2).png", "part_sac - 副本.png", "part_sac copy.png",
			"PART_SAC_v2.png", "part_sac - ╕▒▒╛.png", "part_sac_final.png"]:
		check_eq(tool.call("_match_id", raw.get_basename(), entries), "part_sac", "match '%s'" % raw)
	check_eq(tool.call("_match_id", "random_upload", entries), "", "unknown stays unknown")
	tool.free()


func test_mono_icon_with_transparent_background() -> void:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0))  # transparent pixels stored as white, like many exporters
	img.fill_rect(Rect2i(16, 16, 32, 32), Color(1, 1, 1, 1))
	var res := ArtImporter.process(img, {"mode": "mono", "canvas": [32, 32]})
	check(not res.has("error"), "transparent icon imports")
	var out: Image = res.image
	check(out.get_pixel(16, 16).a > 0.95, "symbol stays opaque")


func test_part_word_covers_all_part_kinds() -> void:
	var words: Dictionary = db.species_names.get("part_word", {})
	for kind: String in Defs.PART_KINDS:
		check(words.has(kind), "fusion.json part_word has %s" % kind)


func test_hero_and_villain_bodies() -> void:
	var by_id := ArtManifest.by_id(ArtManifest.build(db))
	for plan: String in Defs.BODY_PLANS:
		check(by_id.has("body_" + plan), "hero body_%s listed" % plan)
		check(by_id.has("body_%s_enemy" % plan), "villain body_%s_enemy listed" % plan)
		var hero: Dictionary = by_id["body_" + plan]
		var villain: Dictionary = by_id["body_%s_enemy" % plan]
		check_eq(hero.ratio, "2:3", "tall standee ratio")
		check_eq(hero.mode, "cutout", "full-colour standee")
		check(str(hero.prompt).contains("adult"), "%s hero prompt says adult" % plan)
		check(str(villain.prompt).contains("villain"), "%s villain prompt uses the villain style" % plan)
		check(float(villain.size) > float(hero.size), "%s villain is drawn bigger than the hero" % plan)
		check(not (hero.sockets as Dictionary).is_empty() and not (villain.sockets as Dictionary).is_empty(), "%s default sockets" % plan)
		check(str(hero.negative).contains("child"), "%s negatives guard against childlike results" % plan)


func test_enemy_specs_use_villain_art() -> void:
	var team := EnemyFactory.generate(db, rng(3), "insect", 1)
	check(not team.is_empty() and bool(team[0].get("enemy", false)), "generated enemies are flagged")
	var vg := VisualGenome.build(team[0], db)
	check(bool(vg.enemy), "visual genome carries the flag")
	var hero := VisualGenome.build({"template": team[0].template, "genes": []}, db)
	check(not bool(hero.get("enemy", false)), "player units are not enemies")
	# independent of what art the project has: fake the library cache
	var plan: String = vg.body_plan
	ArtLibrary.clear()
	ArtLibrary._cache["res://art/bodies/" + plan] = {"tag": "hero"}
	ArtLibrary._cache["res://art/bodies/%s_enemy" % plan] = {"tag": "villain"}
	check_eq(ArtLibrary.body_for(vg).get("tag", ""), "villain", "enemies use the villain art")
	check_eq(ArtLibrary.body_for(hero).get("tag", ""), "hero", "player units use the hero art")
	ArtLibrary._cache["res://art/bodies/%s_enemy" % plan] = {}
	check_eq(ArtLibrary.body_for(vg).get("tag", ""), "hero", "no villain art -> enemies fall back to the hero art")
	# summoned critters (larvae, spore pods) are not race characters: no standee, procedural art instead
	var brood := VisualGenome.build({"template": "insect_broodling", "genes": []}, db)
	check(bool(brood.get("summon", false)), "summon-only templates are flagged")
	ArtLibrary._cache["res://art/bodies/" + str(brood.body_plan)] = {"tag": "hero"}
	check(ArtLibrary.body_for(brood).is_empty(), "summons never borrow a character standee")
	ArtLibrary.clear()


func test_gpt_request_lists_numbers_and_reasons() -> void:
	var entries := ArtManifest.build(db)
	var by_id := ArtManifest.by_id(entries)
	var req := ArtManifest.to_request(entries, [by_id["part_sac"], by_id["body_biped"]], {"part_sac": "背景有阴影"})
	var n_sac := entries.find(by_id["part_sac"]) + 1
	check(req.contains("【%d】part_sac.png" % n_sac), "item number matches the list numbering")
	check(req.contains("重做：背景有阴影"), "redo reason shown")
	check(req.contains("body_biped.png") and req.contains("缺失"), "missing item shown")
	check(req.contains("共 2 项"), "count")
	check(req.begins_with("$chimera-art 【补图请求】"), "first line invokes the Codex skill and keeps the 【补图请求】 marker")
	var restyle := ArtManifest.to_request(entries, entries, {"part_sac": "风格已更换"}, ArtManifest.RESTYLE_NOTE)
	check(restyle.split("\n")[2].begins_with("风格已更换"), "restyle note sits right under the header")
	check(restyle.contains("共 %d 项" % entries.size()), "restyle request lists every asset")


func test_prompt_text_header_for_chatgpt() -> void:
	var entries := ArtManifest.build(db)
	var txt := ArtManifest.to_text(entries, db.art)
	check(txt.begins_with("《奇美拉纪元》逐项提示词（共 %d 项）" % entries.size()), "header carries the total")
	check(txt.contains("body_hexapod_enemy.png") and txt.contains("定调批"), "header lists the style anchors")
	check(txt.contains("character lineup sheet"), "header carries the style-reference prompt")
	check(txt.contains("【1】") and txt.contains("【%d】" % entries.size()), "items numbered 1..N")
	check(not ArtManifest.to_text(entries).begins_with("《"), "no header without the manifest")


func test_body_and_part_prompts_keep_gene_slots_clear() -> void:
	# genes are grafted onto units at head / eye / back / core / torso / limb, so every standee (hero
	# and villain) must leave those areas uncluttered, and every part must read as a gene organ
	for e: Dictionary in ArtManifest.build(db):
		var prompt := str(e.prompt)
		if str(e.category) == "body":
			check(prompt.contains("uncluttered") and prompt.contains("gene organs are attached there"),
				"%s keeps the gene slots clear" % e.id)
		elif str(e.category) == "part":
			check(prompt.contains("gene organ"), "%s is drawn as a gene organ" % e.id)


func test_assets_json_for_codex() -> void:
	var entries := ArtManifest.build(db)
	var parsed: Variant = JSON.parse_string(ArtManifest.to_json(entries, db.art))
	check(parsed is Dictionary, "valid JSON object")
	var d: Dictionary = parsed
	var items: Array = d.get("items", [])
	check_eq(int(d.get("total", 0)), entries.size(), "total")
	check_eq(items.size(), entries.size(), "one item per asset")
	check_eq(int((items[0] as Dictionary).n), 1, "numbering starts at 1")
	check_eq(str((items[0] as Dictionary).file), str((entries[0] as Dictionary).id) + ".png", "file name = id.png")
	check_eq((d.get("anchor_batch", []) as Array).size(), 7, "anchors carried")
	check(str(d.get("reference_sheet", "")).contains("lineup"), "style reference prompt carried")
	var villains := 0
	for raw: Variant in items:
		if bool((raw as Dictionary).villain):
			villains += 1
	check_eq(villains, 6, "six villain standees flagged")


func test_anchor_batch_ids_exist() -> void:
	var by_id := ArtManifest.by_id(ArtManifest.build(db))
	var anchors: Array = db.art.get("anchor_batch", [])
	check_eq(anchors.size(), 7, "7 style anchors (incl. one villain)")
	for id: String in anchors:
		check(by_id.has(id), "anchor %s is a real asset" % id)

