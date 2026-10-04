extends SceneTree
## Unpacks user asset packs into art_inbox/ (flattened). Cross-platform: uses Godot's
## ZIPReader, so no unzip tool is needed on Windows/macOS/Linux.
##   godot --headless --path . --script res://tools/unpack_assets.gd -- <pack.zip|folder> [more ...]
## Pass ABSOLUTE paths (Godot changes its working directory to the project with --path).
## Takes images (png/jpg/jpeg/webp; .jfif is saved as .jpg) and the pack's credits file
## (credits.txt, also "credits.txt.txt" from hidden-extension renames). The newest pack's
## credit line goes LAST in art_inbox/credits.txt (import_art.gd uses the last line).
## Skips __MACOSX/, hidden files, zips that contain a SKILL.md (the skill package), and
## warns about image formats Godot cannot read (avif, gif, bmp, heic, tif).

const EXTS := ["png", "jpg", "jpeg", "webp"]
const UNSUPPORTED := ["avif", "gif", "bmp", "heic", "heif", "tif", "tiff", "psd"]

var _inbox := ""
var _taken := 0
var _overwritten: PackedStringArray = []
var _skipped: PackedStringArray = []
var _bad_names := false


func _initialize() -> void:
	_inbox = ProjectSettings.globalize_path("res://art_inbox")
	DirAccess.make_dir_recursive_absolute(_inbox)
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: unpack_assets.gd -- <pack.zip|folder> ...")
		quit(2)
		return
	for p in args:
		if DirAccess.dir_exists_absolute(p):
			_from_folder(p)
		elif p.get_extension().to_lower() == "zip" and FileAccess.file_exists(p):
			_from_zip(p)
		else:
			printerr("skip (not a zip or folder): ", p)
	print("unpacked %d file(s) into art_inbox/" % _taken)
	for o in _overwritten:
		print("  replaced existing: ", o)
	for s in _skipped:
		print("  ! 跳过不支持的图片格式：%s（请导出为 PNG 再放进资产包）" % s)
	if _bad_names:
		print("  ! 压缩包里的中文文件夹名/文件名不是 UTF-8 编码（Windows 中文压缩的常见情况）。图片已按文件名正常导入；下次建议资产包里的文件夹用英文名（例如 art_pack）")
	quit(0)


func _from_zip(path: String) -> void:
	var zr := ZIPReader.new()
	if zr.open(path) != OK:
		printerr("cannot open zip: ", path)
		return
	var files := zr.get_files()
	for f in files:
		if f.get_file() == "SKILL.md":
			print("skip %s: it is a skill package, not an art pack" % path.get_file())
			zr.close()
			return
	var n := 0
	for f in files:
		if f.contains("�") or _looks_cp437(f):
			_bad_names = true
		if f.ends_with("/") or f.contains("__MACOSX") or f.get_file().begins_with("."):
			continue
		var name := f.get_file()
		if _wanted(name):
			if _write(name, zr.read_file(f)):
				n += 1
		elif UNSUPPORTED.has(name.get_extension().to_lower()):
			_skipped.append(name)
	zr.close()
	print("%s: %d file(s)" % [path.get_file(), n])


func _from_folder(dir: String) -> void:
	var n := 0
	for f in DirAccess.get_files_at(dir):
		if f.begins_with("."):
			continue
		if _wanted(f):
			if _write(f, FileAccess.get_file_as_bytes(dir.path_join(f))):
				n += 1
		elif UNSUPPORTED.has(f.get_extension().to_lower()):
			_skipped.append(f)
	for d in DirAccess.get_directories_at(dir):
		if not d.begins_with(".") and d != "__MACOSX" and d != "_done" and d != "_packs" and d != "_failed":
			_from_folder(dir.path_join(d))
	if n > 0:
		print("%s/: %d file(s)" % [dir.get_file(), n])


## GBK names in zips without the UTF-8 flag come back as CP437 box-drawing characters.
static func _looks_cp437(name: String) -> bool:
	for i in name.length():
		var c := name.unicode_at(i)
		if c >= 0x2500 and c <= 0x25A0:
			return true
	return false


static func is_credits(name: String) -> bool:
	var l := name.to_lower()
	return l.begins_with("credits") and l.ends_with(".txt")


func _wanted(name: String) -> bool:
	var ext := name.get_extension().to_lower()
	return EXTS.has(ext) or ext == "jfif" or is_credits(name)


func _write(name: String, bytes: PackedByteArray) -> bool:
	if bytes.is_empty():
		return false
	if is_credits(name):
		_merge_credit(bytes)
		return true
	if name.get_extension().to_lower() == "jfif":
		name = name.get_basename() + ".jpg"
	var out := _inbox.path_join(name)
	if FileAccess.file_exists(out):
		_overwritten.append(name)
	var w := FileAccess.open(out, FileAccess.WRITE)
	w.store_buffer(bytes)
	w.close()
	_taken += 1
	return true


## Appends this pack's credit line(s) so the newest line is last; keeps older lines as history.
func _merge_credit(bytes: PackedByteArray) -> void:
	var raw := bytes.get_string_from_utf8().replace("\r", "").strip_edges()
	if raw.begins_with("\uFEFF"):
		raw = raw.substr(1)
	var lines := PackedStringArray()
	for l in raw.split("\n"):
		if l.strip_edges() != "":
			lines.append(l.strip_edges())
	var text := "；".join(lines)  # one line per pack, so the newest pack is always the last line
	if text.contains("\uFFFD") or text == "":
		print("  ! credits.txt 不是 UTF-8 编码（或是空的）：请用记事本打开 → 另存为 → 编码选 UTF-8")
		text = "AI 生成（credits.txt 编码不是 UTF-8，工具待补）"
	var out := _inbox.path_join("credits.txt")
	var old := FileAccess.get_file_as_string(out).strip_edges() if FileAccess.file_exists(out) else ""
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string((old + "\n" if old != "" else "") + text + "\n")
	f.close()
