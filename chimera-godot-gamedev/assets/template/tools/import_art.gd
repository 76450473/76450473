extends SceneTree
## Imports user-made images from art_inbox/ into art/ (references/art-pipeline.md).
##   godot --headless --path . --script res://tools/import_art.gd          (import)
##   godot --headless --path . --script res://tools/import_art.gd -- --dry (report only)
## File name = asset id from docs/ART_TODO.md (part_eye_compound.png). Prefixes and copy
## suffixes are tolerated ("eye_compound (2).png"). Unknown names are listed, never touched.
## Re-importing keeps hand-tuned sidecar keys (offset, rotation, scale_mult, sockets).
## Afterwards run `godot --headless --path . --import` so Godot registers the new PNGs.

const EXTS := ["png", "jpg", "jpeg", "webp"]
const KEEP_KEYS := ["offset", "rotation", "scale_mult", "sockets", "note"]


func _initialize() -> void:
	var dry := OS.get_cmdline_user_args().has("--dry")
	var db := GameData.load_default()
	var entries := ArtManifest.by_id(ArtManifest.build(db))
	var inbox := ProjectSettings.globalize_path("res://art_inbox")
	DirAccess.make_dir_recursive_absolute(inbox)
	var credit := _read_credit(inbox)
	var imported := 0
	var unknown: PackedStringArray = []
	var failed: PackedStringArray = []
	var files := DirAccess.get_files_at(inbox)
	for f in files:
		if not EXTS.has(f.get_extension().to_lower()):
			continue
		var id := _match_id(f.get_basename(), entries)
		if id == "":
			unknown.append(f)
			continue
		var entry: Dictionary = entries[id]
		var img := Image.load_from_file(inbox.path_join(f))
		if img == null or img.is_empty():
			failed.append("%s: 无法读取图片" % f)
			continue
		var res := ArtImporter.process(img, entry)
		if res.has("error"):
			failed.append("%s: %s" % [f, res.error])
			continue
		var out_img: Image = res.image
		var line := "ok  %-26s -> %s  %dx%d" % [f, entry.path.trim_prefix("res://"), out_img.get_width(), out_img.get_height()]
		if dry:
			print("[dry] " + line)
		else:
			var out_png := ProjectSettings.globalize_path(entry.path)
			DirAccess.make_dir_recursive_absolute(out_png.get_base_dir())
			out_img.save_png(out_png)
			_write_sidecar(out_png.get_basename() + ".json", entry, res, f, credit)
			_append_credit(entry.path.trim_prefix("res://"), credit)
			var done := inbox.path_join("_done")
			DirAccess.make_dir_recursive_absolute(done)
			DirAccess.rename_absolute(inbox.path_join(f), done.path_join(f))
			print(line)
			imported += 1
		for w: String in res.warnings:
			print("    ! " + w)
	print("\nimported %d%s" % [imported, " (dry run)" if dry else ""])
	for u in unknown:
		print("  ? 不认识的文件名：%s —— 请改成 docs/ART_TODO.md 里的资产 id（例如 part_eye_compound.png）" % u)
	for e in failed:
		print("  x " + e)
	if imported > 0:
		print("next: godot --headless --path . --import ; then screenshot res://scenes/art_gallery.tscn")
	quit(0)


func _match_id(name: String, entries: Dictionary) -> String:
	var n := name.to_lower().strip_edges().replace(" ", "_").replace("-", "_")
	var re := RegEx.create_from_string("^(.*?)(?:_*\\(\\d+\\)|_v\\d+|_\\d+)$")
	var candidates := [n]
	var m := re.search(n)
	if m != null:
		candidates.append(m.get_string(1))
	for c: String in candidates.duplicate():
		for prefix: String in ["part_", "body_", "bg_", "icon_", "boss_", "cardart_"]:
			candidates.append(prefix + c)
	for c: String in candidates:
		if entries.has(c):
			return c
	return ""


func _read_credit(inbox: String) -> String:
	var p := inbox.path_join("credits.txt")
	if FileAccess.file_exists(p):
		for line in FileAccess.get_file_as_string(p).split("\n"):
			if line.strip_edges() != "":
				return line.strip_edges()
	return "AI 生成（未注明工具，请补 art_inbox/credits.txt）"


func _write_sidecar(path: String, entry: Dictionary, res: Dictionary, source: String, credit: String) -> void:
	var meta := {}
	if FileAccess.file_exists(path):
		var old: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if old is Dictionary:
			for k: String in KEEP_KEYS:
				if (old as Dictionary).has(k):
					meta[k] = old[k]
	var img: Image = res.image
	var pivot: Vector2 = res.pivot
	meta["id"] = entry.id
	meta["mode"] = entry.mode
	meta["pivot"] = [snappedf(pivot.x, 0.5), snappedf(pivot.y, 0.5)]
	meta["scale"] = snappedf(ArtImporter.display_scale(entry, img.get_size()), 0.0001)
	meta["size"] = [img.get_width(), img.get_height()]
	meta["source"] = source
	meta["credit"] = credit
	meta["imported"] = Time.get_date_string_from_system()
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(meta, "  "))
	f.close()


func _append_credit(rel_path: String, credit: String) -> void:
	var p := ProjectSettings.globalize_path("res://CREDITS.md")
	var text := FileAccess.get_file_as_string(p) if FileAccess.file_exists(p) else "# Credits\n"
	var row := "| %s | 项目作者（AI 辅助生成） | CC BY-SA 4.0 | %s |" % [rel_path, credit]
	var lines := text.strip_edges(false, true).split("\n")
	var replaced := false
	for i in lines.size():
		if lines[i].begins_with("| %s |" % rel_path):
			lines[i] = row
			replaced = true
	if not replaced:
		lines.append(row)
	var f := FileAccess.open(p, FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	f.close()
