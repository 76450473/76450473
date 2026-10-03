extends SceneTree
## Headless test runner:
##   godot --headless --path . --import            (once per fresh checkout: registers class_name)
##   godot --headless --path . --script res://tests/run_tests.gd
## Optional filter:  ... --script res://tests/run_tests.gd -- test_fusion
## Exit code 0 = all green. Runtime script errors (null calls, bad index...) raised while a
## test runs are captured by a Logger and fail that test, so a crash can never look green.

var _errors: PackedStringArray = []


class _ErrorCatcher:
	extends Logger
	var sink: Callable

	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		sink.call("%s (%s:%d %s)" % [rationale if rationale != "" else code, file.get_file(), line, function])

	func _log_message(_message: String, _error: bool) -> void:
		pass


func _initialize() -> void:
	var catcher := _ErrorCatcher.new()
	catcher.sink = func(msg: String) -> void: _errors.append(msg)
	OS.add_logger(catcher)
	var filter := ""
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		filter = args[0]
	var files: PackedStringArray = []
	for f in DirAccess.get_files_at("res://tests"):
		if f.begins_with("test_") and f.ends_with(".gd") and f != "test_case.gd":
			if filter == "" or f.contains(filter):
				files.append(f)
	files.sort()
	var total := 0
	var failed := 0
	for f in files:
		var script: GDScript = load("res://tests/" + f)
		if script == null or not script.can_instantiate():
			printerr("FAIL  %s: could not load (parse/compile error, see SCRIPT ERROR above)" % f)
			failed += 1
			continue
		for m: Dictionary in script.get_script_method_list():
			var name: String = m.name
			if not name.begins_with("test_"):
				continue
			total += 1
			var tc: TestCase = script.new()
			_errors.clear()
			tc.before_all()
			tc.call(name)
			for e in _errors:
				tc.failures.append("runtime error: " + e)
			if tc.assertions == 0:
				tc.failures.append("no assertions ran (crashed before first check?)")
			if tc.failures.is_empty():
				print("ok    %s::%s (%d)" % [f, name, tc.assertions])
			else:
				failed += 1
				for msg in tc.failures:
					printerr("FAIL  %s::%s — %s" % [f, name, msg])
	print("\n%d tests, %d failed" % [total, failed])
	quit(1 if failed > 0 or total == 0 else 0)
