extends SceneTree
## Imports user-made images from art_inbox/ into art/ (references/art-pipeline.md).
##   godot --headless --path . --script res://tools/import_art.gd          (import)
##   godot --headless --path . --script res://tools/import_art.gd -- --dry (report only)
## File name = asset id from docs/ART_TODO.md (part_eye_compound.png). Tolerated: missing
## prefixes, copy suffixes ("eye_compound (2).png", "… - 副本.png", "… copy.png") and doubled
## extensions from Windows' hidden-extension renames ("part_sac.png.png"). The real format is
## detected from the file bytes, so a WebP/JPEG saved under a .png name still loads.
## Unknown names are listed, never touched. Last line: "summary: imported=N unknown=N failed=N".
## Re-importing keeps hand-tuned sidecar keys (offset, rotation, scale_mult, sockets).
## Afterwards run `godot --headless --path . --import` so Godot registers the new PNGs.

const EXTS := ["png", "jpg", "jpeg", "webp", "jfif"]
const UNSUPPORTED := ["avif", "heic", "heif", "gif", "bmp", "tif", "tiff", "psd"]
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
		if UNSUPPORTED.has(f.get_extension().to_lower()):
			failed.append("%s: 格式不支持（%s），请导出为 PNG" % [f, f.get_extension()])
			continue
		if not EXTS.has(f.get_extension().to_lower()):
			continue
		var id := _match_id(f.get_basename(), entries)
		if id == "":
			unknown.append(f)
			continue
		var entry: Dictionary = entries[id]
		var img := _load_image(inbox.path_join(f))
		if img == null or img.is_empty():
			failed.append("%s: 文件名正确，但图片内容读不出来（可能损坏或格式不支持）：请重新导出为 PNG" % f)
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
			var file_credit := _previous_credit(out_png.get_basename() + ".json", f, credit)
			_write_sidecar(out_png.get_basename() + ".json", entry, res, f, file_credit)
			_append_credit(entry.path.trim_prefix("res://"), file_credit)
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
	print("summary: imported=%d unknown=%d failed=%d" % [imported, unknown.size(), failed.size()])
	if imported > 0:
		print("next: godot --headless --path . --import ; then screenshot res://scenes/art_gallery.tscn")
	quit(0)


func _match_id(name: String, entries: Dictionary) -> String:
	var n := name.to_lower().strip_edges()
	while EXTS.has(n.get_extension()):  # "part_sac.png" (+ hidden ".png") -> "part_sac"
		n = n.get_basename()
	n = n.replace(" ", "_").replace("-", "_").replace("　", "_")
	var re := RegEx.create_from_string("^(.*?)_*(?:\\(\\d+\\)|v\\d+|\\d+|(?:copy|副本|拷贝)(?:_*\\(?\\d+\\)?)?)$")
	var candidates := [n]
	var m := re.search(n)
	if m != null:
		candidates.append(m.get_string(1).rstrip("_"))
	for c: String in candidates.duplicate():
		for prefix: String in ["part_", "body_", "bg_", "icon_", "boss_", "cardart_"]:
			candidates.append(prefix + c)
	for c: String in candidates:
		if entries.has(c):
			return c
	# last resort: the longest asset id that the name starts with, followed by "_"
	# ("part_spear_final", "part_spear___<garbled GBK 副本>") -> part_spear
	var best := ""
	for id: String in entries:
		for c: String in [n, "part_" + n, "icon_" + n]:
			if c.begins_with(id + "_") and id.length() > best.length():
				best = id
	return best


## Picks the decoder from the file signature, not the extension.
func _load_image(path: String) -> Image:
	var bytes := FileAccess.get_file_as_bytes(path)
	if bytes.size() < 12:
		return null
	var img := Image.new()
	var err := ERR_FILE_UNRECOGNIZED
	if bytes[0] == 0x89 and bytes[1] == 0x50 and bytes[2] == 0x4E and bytes[3] == 0x47:
		err = img.load_png_from_buffer(bytes)
	elif bytes[0] == 0xFF and bytes[1] == 0xD8:
		err = img.load_jpg_from_buffer(bytes)
	elif bytes.slice(0, 4).get_string_from_ascii() == "RIFF" and bytes.slice(8, 12).get_string_from_ascii() == "WEBP":
		err = img.load_webp_from_buffer(bytes)
	return img if err == OK else null


## The NEWEST credit line wins (unpack_assets.gd puts the latest pack's line last).
func _read_credit(inbox: String) -> String:
	var p := inbox.path_join("credits.txt")
	var fallback := "AI 生成（未注明工具，请补 credits.txt）"
	if not FileAccess.file_exists(p):
		return fallback
	var last := ""
	for line in FileAccess.get_file_as_string(p).split("\n"):
		if line.strip_edges() != "":
			last = line.strip_edges()
	if last.contains("\uFFFD"):
		print("  ! credits.txt 不是 UTF-8 编码，读不出来：请用记事本打开 → 另存为 → 编码选 UTF-8，再提供一次")
		return fallback
	return last if last != "" else fallback


## Re-importing the SAME original keeps the credit it was first imported with (a newer pack
## made with another tool must not re-credit older art).
func _previous_credit(meta_path: String, source: String, fallback: String) -> String:
	if FileAccess.file_exists(meta_path):
		var old: Variant = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
		if old is Dictionary and str((old as Dictionary).get("source", "")) == source and (old as Dictionary).has("credit"):
			return str(old.credit)
	return fallback


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
