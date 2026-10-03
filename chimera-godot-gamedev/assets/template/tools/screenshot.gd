extends SceneTree
## Renders a scene for N frames and saves a PNG so an AI agent can LOOK at the result.
## Needs a real renderer (do NOT pass --headless). On a Linux server wrap with xvfb-run.
##   godot --path . --script res://tools/screenshot.gd -- res://scenes/main.tscn screenshots/main.png 90
## Optional 4th arg: a key to press before capture, e.g. "R" (random set) or "F" (fusion).

var _scene_path := "res://scenes/main.tscn"
var _out := "screenshots/shot.png"
var _frames := 90
var _key := ""
var _frame := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		_scene_path = args[0]
	if args.size() > 1:
		_out = args[1]
	if args.size() > 2:
		_frames = int(args[2])
	if args.size() > 3:
		_key = args[3]


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 2:  # autoloads exist from the first frame on
		var packed: PackedScene = load(_scene_path)
		if packed == null:
			printerr("screenshot: cannot load ", _scene_path)
			quit(1)
			return true
		root.add_child(packed.instantiate())
	if _frame == 10 and _key != "":
		var ev := InputEventKey.new()
		ev.keycode = OS.find_keycode_from_string(_key)
		ev.pressed = true
		root.push_input(ev)
	if _frame >= _frames:
		var img := root.get_texture().get_image()
		var path := _out if _out.is_absolute_path() else ProjectSettings.globalize_path("res://" + _out)
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		var err := img.save_png(path)
		print("screenshot: ", path if err == OK else "FAILED %d" % err)
		quit(0 if err == OK else 1)
	return false
