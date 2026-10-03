extends SceneTree
## Unpacks user asset packs into art_inbox/ (flattened). Cross-platform: uses Godot's
## ZIPReader, so no unzip tool is needed on Windows/macOS/Linux.
##   godot --headless --path . --script res://tools/unpack_assets.gd -- <pack.zip|folder> [more ...]
## Pass ABSOLUTE paths (Godot changes its working directory to the project with --path).
## Takes images (png/jpg/jpeg/webp) and credits.txt; skips __MACOSX/, hidden files and
## zips that contain a SKILL.md (that is the skill package, not art).

const EXTS := ["png", "jpg", "jpeg", "webp"]

var _inbox := ""
var _taken := 0
var _overwritten: PackedStringArray = []


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
		if f.ends_with("/") or f.contains("__MACOSX") or f.get_file().begins_with("."):
			continue
		if _wanted(f.get_file()):
			_write(f.get_file(), zr.read_file(f))
			n += 1
	zr.close()
	print("%s: %d file(s)" % [path.get_file(), n])


func _from_folder(dir: String) -> void:
	var n := 0
	for f in DirAccess.get_files_at(dir):
		if not f.begins_with(".") and _wanted(f):
			_write(f, FileAccess.get_file_as_bytes(dir.path_join(f)))
			n += 1
	for d in DirAccess.get_directories_at(dir):
		if not d.begins_with(".") and d != "__MACOSX" and d != "_done":
			_from_folder(dir.path_join(d))
	if n > 0:
		print("%s/: %d file(s)" % [dir.get_file(), n])


func _wanted(name: String) -> bool:
	return EXTS.has(name.get_extension().to_lower()) or name.to_lower() == "credits.txt"


func _write(name: String, bytes: PackedByteArray) -> void:
	if bytes.is_empty():
		return
	var out := _inbox.path_join(name)
	if name.to_lower() == "credits.txt" and FileAccess.file_exists(out):
		# keep every credit line from every pack
		var old := FileAccess.get_file_as_string(out)
		var f := FileAccess.open(out, FileAccess.WRITE)
		f.store_string(old.strip_edges() + "\n" + bytes.get_string_from_utf8().strip_edges() + "\n")
		f.close()
		return
	if FileAccess.file_exists(out):
		_overwritten.append(name)
	var w := FileAccess.open(out, FileAccess.WRITE)
	w.store_buffer(bytes)
	w.close()
	_taken += 1
