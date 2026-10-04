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
	check(str(e.prompt).contains("bright saturated green"), "accent clause present")
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
