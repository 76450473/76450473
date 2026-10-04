extends SceneTree
## Compiles every .gd in the project and lists the ones that fail (parse/compile errors).
##   godot --headless --path . --script res://tools/check_scripts.gd
## Run after --import. Exit code 1 if anything is broken; the SCRIPT ERROR lines above
## the "BROKEN" line point at the first real error.
func _initialize() -> void:
	var bad := 0
	for path in _walk("res://"):
		var s: GDScript = load(path)
		if s == null or not s.can_instantiate():
			printerr("BROKEN ", path)
			bad += 1
	print("checked, broken=", bad)
	quit(1 if bad else 0)
func _walk(dir: String) -> PackedStringArray:
	var out: PackedStringArray = []
	for d in DirAccess.get_directories_at(dir):
		var sub := dir.path_join(d)
		# skip hidden dirs, Godot-ignored dirs and nested projects (e.g. an unzipped skill folder)
		if d.begins_with(".") or FileAccess.file_exists(sub.path_join(".gdignore")) \
				or FileAccess.file_exists(sub.path_join("project.godot")):
			continue
		out.append_array(_walk(sub))
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	return out
