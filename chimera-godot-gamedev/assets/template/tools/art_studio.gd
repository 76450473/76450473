extends SceneTree
## Art studio: GPT image generation -> Claude's first pass -> the user's review page -> game.
## Normally run through the skill wrapper, which finds Godot and the workspace:
##   bash SKILL_DIR/scripts/art_studio.sh <workspace> <command> [args]
## Direct form (absolute workspace path):
##   godot --headless --path <W>/游戏 --script res://tools/art_studio.gd -- <command> --ws <W> [options]
## Commands:
##   status                     what waits where, money spent, the next step
##   ping                       free key + connection check (GET /models, generates nothing)
##   plan <sel>                 list + cost estimate; sends nothing
##   gen <sel> [--n N] [--quality low|medium|high] [--max-usd X] [--again] [--no-ref]
##   apply                      apply Claude's first-pass verdicts from 美术资产/初审.json
##   page                       rebuild 美术资产/审核页面.html
##   trial-list | trial-done --trial <dir>     (used by "art_studio.sh trial")
##   user-apply [--file F]      apply the user's 复审结果.json (approved -> 已通过/)
##   sync-prepare               copy new/changed 已通过/ originals into art_inbox/ (+ credits.json)
## <sel>: anchor | p1 | p2 | p3 | all | redo | asset ids, comma separated (e.g. part_sac,body_biped)
## The key from GPTapi.txt is only ever sent to the API host. It is never printed or written anywhere.
## Workspace layout, review rubric and protocols: references/art-studio.md (skill).

const ART := "美术资产"
const DIRS := ["候选", "候选/_对比", "待复审", "待复审/试装", "已通过", "淘汰", ".history"]
const SCREENS := ["art_gallery", "art_parts", "art_images", "art_enemies", "main"]
const IMG_EXTS := ["png", "jpg", "jpeg", "webp"]
const RETRY_WAIT := [5.0, 15.0, 30.0, 60.0]

var ws := ""
var art := ""
var cmd := ""
var pos: Array = []
var opts := {}
var db: GameData
var entries: Array = []
var by_id := {}
var anchors: Array = []
var state := {}
var cfg := {}
var key := ""
var _fatal := ""
var _dropped := {}
var _queue: Array = []
var _workers_left := 0
var _run_spent := 0.0
var _run_cap := 0.0
var _stopped_by_cap := false
var _gen_ok := 0
var _gen_failed := 0
var _reserved := 0.0
var _total_cap := 0.0
var _had_success := false
var _gen_running := false
var _dirty_assets := {}
var _dirty_keys := {}
var _dirty_imported := {}
var _unsaved_spend := 0.0
var _unsaved_maybe := 0.0
const LOCK_STALE_SEC := 120


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var a: String = args[i]
		if a.begins_with("--"):
			var name := a.substr(2)
			if ["again", "no-ref", "force", "dry"].has(name):
				opts[name] = true
			elif i + 1 < args.size():
				opts[name] = args[i + 1]
				i += 1
		elif cmd == "":
			cmd = a
		else:
			pos.append(a)
		i += 1
	ws = str(opts.get("ws", "")).replace("\\", "/").trim_suffix("/")
	if cmd == "" or ws == "" or not DirAccess.dir_exists_absolute(ws):
		printerr("usage: art_studio.gd -- <status|ping|plan|gen|apply|page|trial-list|trial-done|user-apply|sync-prepare> --ws <workspace dir>")
		quit(2)
		return
	art = ws.path_join(ART)
	for d: String in DIRS:
		DirAccess.make_dir_recursive_absolute(art.path_join(d))
	if not FileAccess.file_exists(art.path_join(".gdignore")):
		FileAccess.open(art.path_join(".gdignore"), FileAccess.WRITE).close()
	db = GameData.load_default()
	entries = ArtManifest.build(db)
	by_id = ArtManifest.by_id(entries)
	anchors = db.art.get("anchor_batch", [])
	state = _load_state()
	_run()


func _run() -> void:
	await process_frame  # nodes (HTTPRequest) only work once the tree is running
	var code := 0
	match cmd:
		"status":
			code = _cmd_status()
		"ping":
			code = await _cmd_ping()
		"plan":
			code = _cmd_plan()
		"gen":
			code = await _cmd_gen()
		"apply":
			code = _cmd_apply()
		"page":
			code = _build_page()
		"trial-list":
			code = _cmd_trial_list()
		"trial-done":
			code = _cmd_trial_done()
		"user-apply":
			code = _cmd_user_apply()
		"sync-prepare":
			code = _cmd_sync_prepare()
		_:
			printerr("unknown command: ", cmd)
			code = 2
	quit(code)


# ================================================================== key + settings

## {"found", "file", "errors", "warnings"}; fills `key` and `cfg`. Never prints the key.
func _load_key() -> Dictionary:
	var info := {"found": false, "file": "", "errors": PackedStringArray(), "warnings": PackedStringArray()}
	var text := ""
	var game_dir := ProjectSettings.globalize_path("res://").trim_suffix("/")
	for dir: String in [ws, game_dir]:
		for f in DirAccess.get_files_at(dir):
			var l := f.to_lower()
			if l == "gptapi" or l.begins_with("gptapi.txt") or l == "gptapi.text":
				text = StudioCore.decode_text(FileAccess.get_file_as_bytes(dir.path_join(f)))
				info.found = true
				info.file = f if dir == ws else "游戏/" + f
				break
		if info.found:
			break
	var parsed := {"key": "", "settings": {}, "errors": PackedStringArray(), "warnings": PackedStringArray()}
	if info.found:
		parsed = StudioCore.parse_key_file(text)
	elif OS.get_environment("OPENAI_API_KEY") != "":
		parsed = StudioCore.parse_key_file(OS.get_environment("OPENAI_API_KEY"))
		info.found = true
		info.file = "环境变量 OPENAI_API_KEY"
	key = str(parsed.key) if (parsed.errors as PackedStringArray).is_empty() else ""
	info.errors = parsed.errors
	info.warnings = parsed.warnings
	var overrides := {}
	if opts.has("n") and str(opts.n).is_valid_int():
		overrides["n"] = clampi(int(opts.n), 1, 8)
	if opts.has("quality") and ["low", "medium", "high", "auto"].has(str(opts.quality)):
		overrides["quality"] = str(opts.quality)
	if opts.has("model"):
		overrides["model"] = str(opts.model)
	var env := {}
	for name: String in ["HTTPS_PROXY", "https_proxy", "ALL_PROXY", "all_proxy", "HTTP_PROXY", "http_proxy"]:
		env[name] = OS.get_environment(name)
	cfg = StudioCore.effective_settings(parsed.settings, overrides, env)
	return info


func _require_key() -> bool:
	var info := _load_key()
	for w: String in info.warnings:
		print("  ! " + w)
	if not info.found:
		print("没有找到 GPTapi.txt：在工作区（%s）新建 GPTapi.txt，第一行写 OpenAI 的 Key。没有 Key 就用手动模式（用户自己出图）。" % ws)
		return false
	if not (info.errors as PackedStringArray).is_empty():
		for e: String in info.errors:
			print("x " + e)
		return false
	return true


# ================================================================== state

## Raw 记录.json ({} when missing or unreadable). A leftover .tmp is a save that crashed before its rename.
func _read_state_file() -> Dictionary:
	var p := art.path_join("记录.json")
	for path: String in [p, p + ".tmp"]:
		if FileAccess.file_exists(path):
			var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			if v is Dictionary:
				return v
	return {}


func _load_state() -> Dictionary:
	var p := art.path_join("记录.json")
	var d := _read_state_file()
	if d.is_empty():
		if FileAccess.file_exists(p):
			print("  ! 记录.json 读不出来（可能被手动改坏了），已备份为 记录.坏.json 并重新开始记录")
			DirAccess.rename_absolute(p, art.path_join("记录.坏.json"))
		d = StudioCore.new_state()
	for k: String in ["assets", "imported"]:
		if not d.get(k, null) is Dictionary:
			d[k] = {}
	if str(d.get("workspace_id", "")) == "":  # keeps review pages of different workspaces apart
		d["workspace_id"] = "%x%04x" % [int(Time.get_unix_time_from_system()), randi() % 65536]
		_dirty_keys["workspace_id"] = true
	return d


## Money that may have been charged without a usable result (timeouts, dropped connections).
func _add_spend(usd: float, maybe: bool) -> void:
	_run_spent += usd
	_unsaved_spend += usd
	state["spent_usd"] = float(state.get("spent_usd", 0.0)) + usd
	if maybe:
		_unsaved_maybe += usd
		state["maybe_billed_usd"] = float(state.get("maybe_billed_usd", 0.0)) + usd


func _touch(id: String) -> void:
	_dirty_assets[id] = true


func _set_key(k: String, v: Variant) -> void:
	state[k] = v
	_dirty_keys[k] = true


## Merge-save: another studio command may have saved since this one loaded (user-apply while a gen
## runs in the background, for example). Only what THIS process changed is written over the file.
func _save_state() -> void:
	var disk := _read_state_file()
	if not disk.is_empty():
		for k: String in ["assets", "imported"]:
			if not disk.get(k, null) is Dictionary:
				disk[k] = {}
		for id: String in _dirty_assets:
			(disk.assets as Dictionary)[id] = (state.assets as Dictionary).get(id, {})
		for f: String in _dirty_imported:
			(disk.imported as Dictionary)[f] = (state.imported as Dictionary).get(f, "")
		for k: String in _dirty_keys:
			disk[k] = state.get(k)
		disk["spent_usd"] = snappedf(float(disk.get("spent_usd", 0.0)) + _unsaved_spend, 0.0001)
		disk["maybe_billed_usd"] = snappedf(float(disk.get("maybe_billed_usd", 0.0)) + _unsaved_maybe, 0.0001)
		state = disk
	_unsaved_spend = 0.0
	_unsaved_maybe = 0.0
	_dirty_assets.clear()
	_dirty_imported.clear()
	_dirty_keys.clear()
	var p := art.path_join("记录.json")
	var f := FileAccess.open(p + ".tmp", FileAccess.WRITE)
	f.store_string(JSON.stringify(state, "  "))
	f.close()
	if DirAccess.rename_absolute(p + ".tmp", p) != OK:  # Windows: rename does not replace
		DirAccess.remove_absolute(p)
		DirAccess.rename_absolute(p + ".tmp", p)


## A gen that is still running holds 美术资产/.gen.lock and refreshes it every 30 s.
func _live_gen_lock() -> Dictionary:
	var p := art.path_join(".gen.lock")
	if not FileAccess.file_exists(p):
		return {}
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(p))
	if not v is Dictionary:
		return {}
	if int(Time.get_unix_time_from_system()) - int((v as Dictionary).get("beat", 0)) > LOCK_STALE_SEC:
		return {}  # its process died (killed session, crash): the lock is stale
	return v


func _write_gen_lock(started: String) -> void:
	var f := FileAccess.open(art.path_join(".gen.lock"), FileAccess.WRITE)
	f.store_string(JSON.stringify({"started": started, "beat": int(Time.get_unix_time_from_system()),
		"sel": " ".join(PackedStringArray(pos))}))
	f.close()


func _heartbeat(started: String) -> void:
	while _gen_running:
		_write_gen_lock(started)
		await create_timer(30.0).timeout


func _now() -> String:
	return Time.get_datetime_string_from_system(false, true)


func _status_of(id: String) -> String:
	return str((state.assets as Dictionary).get(id, {}).get("status", ""))


func _present() -> Dictionary:
	var out := {}
	for e: Dictionary in entries:
		if ArtManifest.is_present(e):
			out[e.id] = true
	return out


## {asset_id: abs path} of approved originals in 已通过/ (file name = asset id).
func _approved_files() -> Dictionary:
	var out := {}
	for f in DirAccess.get_files_at(art.path_join("已通过")):
		if IMG_EXTS.has(f.get_extension().to_lower()) and by_id.has(f.get_basename()):
			out[f.get_basename()] = art.path_join("已通过").path_join(f)
	return out


func _files_of(dir: String, id: String) -> Array:
	var out: Array = []
	for f in DirAccess.get_files_at(art.path_join(dir)):
		if StudioCore.id_of_candidate(f) == id and f.contains("__"):
			out.append(f)
	out.sort_custom(func(a: String, b: String) -> bool: return a.naturalnocasecmp_to(b) < 0)
	return out


func _move(from_dir: String, to_dir: String, f: String) -> void:
	var src := art.path_join(from_dir).path_join(f)
	if not FileAccess.file_exists(src):
		return
	var dst := art.path_join(to_dir).path_join(f)
	if FileAccess.file_exists(dst):
		DirAccess.remove_absolute(dst)
	DirAccess.rename_absolute(src, dst)


# ================================================================== status

func _cmd_status() -> int:
	var info := _load_key()
	print("工作区：", ws)
	if info.found and (info.errors as PackedStringArray).is_empty():
		print("生图：已找到 %s（格式正常）｜%s · 质量 %s · 每项 %d 个候选 · 单次上限 $%.2f%s" % [info.file, cfg.model,
			cfg.quality, int(cfg.n), float(cfg.budget), " · 走代理" if _uses_proxy() else ""])
		if str(cfg.base_url) != StudioCore.DEFAULTS.base_url:
			print("      接口地址：%s" % StudioCore.host_of(str(cfg.base_url)))
	elif info.found:
		print("生图：%s 有问题 → %s" % [info.file, "；".join(info.errors)])
	else:
		print("生图：没有 GPTapi.txt → 手动模式（用户自己出图，放进 美术资产/已通过/ 或者打包成 zip）")
	for w: String in info.warnings:
		print("  ! " + w)
	var c := StudioCore.counts(state)
	var present := _present()
	var missing := 0
	var p1_missing := 0
	for e: Dictionary in entries:
		var st := _status_of(e.id)
		if not present.has(e.id) and st != "approved":
			missing += 1
			if int(e.priority) == 1:
				p1_missing += 1
	print("资产：共 %d 项｜游戏里已有 %d｜已通过待同步/已同步 %d｜还没有的 %d（P1 %d）" % [entries.size(), present.size(), int(c.approved), missing, p1_missing])
	var lines := {"candidates": "待 Claude 初审", "claude_redo": "Claude 要求重画", "failed": "生成失败",
		"user_review": "等用户复审", "user_rejected": "用户退回（要改提示词再画）"}
	for st: String in lines:
		var ids: Array = []
		for id: String in state.assets:
			if _status_of(id) == st:
				ids.append(id)
		if not ids.is_empty():
			ids.sort()
			print("  %s %d：%s%s" % [lines[st], ids.size(), ", ".join(PackedStringArray(ids.slice(0, 12))), " …" if ids.size() > 12 else ""])
	print("已花费：$%.2f（估算，以 OpenAI 账单为准）" % float(state.get("spent_usd", 0.0)))
	var lock := _live_gen_lock()
	if not lock.is_empty():
		print("  后台 gen 正在运行（%s 开始：%s）——它结束前不要再开 gen" % [str(lock.get("started", "?")), str(lock.get("sel", ""))])
	if float(state.get("maybe_billed_usd", 0.0)) > 0.0:
		print("  其中约 $%.2f 是超时/断线、可能已计费但没拿到图的请求" % float(state.maybe_billed_usd))
	var unsynced := _unsynced().size()
	var rejected_no_prompt := 0
	for id: String in state.assets:
		var a: Dictionary = state.assets[id]
		if str(a.get("status", "")) == "user_rejected" and not bool(a.get("prompt_after_reject", false)):
			rejected_no_prompt += 1
	var result_file := _find_result_file() != ""
	var review_file := FileAccess.file_exists(art.path_join("初审.json"))
	print("STATE candidates=%d claude_redo=%d failed=%d user_review=%d user_rejected=%d approved=%d unsynced=%d missing=%d key=%s result_file=%s first_pass_file=%s gen_running=%s" % [
		c.candidates, c.claude_redo, c.failed, c.user_review, c.user_rejected, c.approved, unsynced, missing,
		"ok" if key != "" else ("bad" if info.found else "none"), "yes" if result_file else "no", "yes" if review_file else "no",
		"yes" if not lock.is_empty() else "no"])
	var nxt := ""
	if result_file:
		nxt = "用户已提交复审 → art_studio.sh <W> user-apply"
	elif review_file:
		nxt = "初审.json 还没应用 → art_studio.sh <W> apply"
	elif int(c.candidates) > 0:
		nxt = "Claude 初审：逐个 Read 美术资产/候选/_对比/<id>.png（上排原图 1..n，下排处理后），写 美术资产/初审.json，再 apply"
	elif rejected_no_prompt > 0:
		nxt = "用户退回了 %d 项：先按意见改提示词（初审.json 里写 {\"<id>\": {\"prompt\": \"...\"}}）→ apply → plan redo → gen redo" % rejected_no_prompt
	elif int(c.claude_redo) + int(c.failed) + int(c.user_rejected) > 0:
		nxt = "重画：art_studio.sh <W> plan redo（把费用告诉用户）→ gen redo"
	elif unsynced > 0:
		nxt = "已通过的图还没进游戏 → art_studio.sh <W> sync"
	elif int(c.user_review) > 0:
		if StudioCore.review_signature(state) == str(state.get("page_sig", "")) and FileAccess.file_exists(art.path_join("审核页面.html")):
			nxt = "等用户复审：页面已是最新，直接 art_studio.sh <W> serve（run_in_background；用户之前没提交的选择会保留）"
		else:
			nxt = "等用户复审：art_studio.sh <W> trial（试装截图 + 页面）→ art_studio.sh <W> serve（run_in_background）"
	elif missing > 0:
		nxt = ("下一批：art_studio.sh <W> plan %s（先给用户看费用）" % ("anchor" if _anchor_open() else "p1" if p1_missing > 0 else "p2")) if key != "" \
			else "手动模式：把缺的资产提示词（docs/ART_TODO.md）发给用户"
	else:
		nxt = "美术全部到位"
	print("next: " + nxt)
	return 0


func _uses_proxy() -> bool:
	var no_proxy := OS.get_environment("NO_PROXY") + "," + OS.get_environment("no_proxy")
	return not StudioCore.parse_proxy(str(cfg.get("proxy", ""))).is_empty() \
		and StudioCore.should_proxy(StudioCore.host_of(str(cfg.base_url)), no_proxy)


func _anchor_open() -> bool:
	var present := _present()
	for id: String in anchors:
		if _status_of(id) != "approved" and not present.has(id):
			return true
	return false


# ================================================================== HTTP

func _http(method: int, url: String, headers: PackedStringArray, body: PackedByteArray, follow: bool = false) -> Dictionary:
	var req := HTTPRequest.new()
	req.timeout = float(cfg.get("timeout", 300))
	req.use_threads = true
	req.max_redirects = 8 if follow else 0  # never re-send the Authorization header to another host
	var px := StudioCore.parse_proxy(str(cfg.get("proxy", "")))
	var no_proxy := OS.get_environment("NO_PROXY") + "," + OS.get_environment("no_proxy")
	if not px.is_empty() and StudioCore.should_proxy(StudioCore.host_of(url), no_proxy):
		req.set_http_proxy(str(px.host), int(px.port))
		req.set_https_proxy(str(px.host), int(px.port))
	root.add_child(req)
	var err := req.request_raw(url, headers, method, body)
	if err != OK:
		req.queue_free()
		return {"result": HTTPRequest.RESULT_CANT_CONNECT, "code": 0, "headers": PackedStringArray(), "body": PackedByteArray()}
	var r: Array = await req.request_completed
	req.queue_free()
	return {"result": int(r[0]), "code": int(r[1]), "headers": r[2], "body": r[3]}


func _auth() -> PackedStringArray:
	return PackedStringArray(["Authorization: Bearer " + key, "User-Agent: chimera-epoch-art-studio"])


## JSON body of a response; a relay's HTML/plain error page becomes {"error": {"message": <start>}}.
## Everything that came from the network is redacted (relays sometimes echo the Authorization header).
func _json_body(resp: Dictionary) -> Dictionary:
	var text := StudioCore.redact((resp.body as PackedByteArray).get_string_from_utf8(), key)
	var j := JSON.new()  # instance parse: no engine error spam on empty / HTML bodies
	if j.parse(text) == OK and j.data is Dictionary:
		return j.data
	if text.strip_edges() != "":
		return {"error": {"message": text.strip_edges().left(160)}}
	return {}


## explain_error with the key scrubbed from the message.
func _explain(resp: Dictionary, body: Dictionary) -> Dictionary:
	var ex := StudioCore.explain_error(int(resp.result), int(resp.code), body, StudioCore.host_of(str(cfg.base_url)),
		str(cfg.model), _uses_proxy(), _had_success)
	ex["msg"] = StudioCore.redact(str(ex.msg), key)
	return ex


static func _retry_after(resp: Dictionary) -> float:
	for h: String in resp.headers:
		if h.to_lower().begins_with("retry-after:"):
			var v := h.substr(12).strip_edges()
			if v.is_valid_float():
				return clampf(float(v), 1.0, 120.0)
	return -1.0


# ================================================================== ping

func _cmd_ping() -> int:
	if not _require_key():
		return 3
	var host := StudioCore.host_of(str(cfg.base_url))
	var resp := await _http(HTTPClient.METHOD_GET, str(cfg.base_url) + "/models", _auth(), PackedByteArray())
	var body := _json_body(resp)
	if int(resp.result) == HTTPRequest.RESULT_SUCCESS and int(resp.code) == 200:
		var ids: Array = []
		for m: Variant in body.get("data", []):
			if m is Dictionary:
				ids.append(str((m as Dictionary).get("id", "")))
		print("Key 有效，能连上 %s。" % host)
		if ids.has(str(cfg.model)):
			print("账户的模型列表里有 %s。" % cfg.model)
		else:
			print("模型列表里没看到 %s（中转服务常见；真正生成时才能确定能不能用）。" % cfg.model)
		print("PING ok")
		return 0
	var ex := _explain(resp, body)
	print("x " + str(ex.msg))
	print("PING fail")
	return 3


# ================================================================== plan / gen

func _selection() -> Dictionary:
	var sel := " ".join(PackedStringArray(pos))
	if sel.strip_edges() == "":
		return {}
	return StudioCore.select(entries, sel, state.assets, anchors, _present(), bool(opts.get("again", false)), int(cfg.max_rounds))


## Style references for one asset: approved originals of the same group + 美术资产/风格参考/ images
## (creature group only). [] when style_ref=off or --no-ref.
func _refs_for(entry: Dictionary) -> Array:
	if str(cfg.style_ref) == "off" or bool(opts.get("no-ref", false)):
		return []
	var approved := {}
	var files := _approved_files()
	for id: String in files:
		approved[id] = files[id]
	var refs := StudioCore.pick_refs(entry, approved, by_id, anchors, 2)
	if StudioCore.ref_group(entry) == "creature":
		var sdir := art.path_join("风格参考")
		if DirAccess.dir_exists_absolute(sdir):
			for f in DirAccess.get_files_at(sdir):
				if refs.size() >= 3:
					break
				if IMG_EXTS.has(f.get_extension().to_lower()):
					refs.append(sdir.path_join(f))
	return refs


func _estimate(entry: Dictionary, n: int, refs: int) -> float:
	var prompt := StudioCore.gpt_prompt(entry, str(StudioCore.asset(state, entry.id).get("prompt", "")), refs > 0)
	return StudioCore.estimate_usd(str(cfg.model), str(cfg.quality), StudioCore.api_size(str(entry.ratio)), n, refs, prompt.length())


func _print_plan(sel: Dictionary) -> float:
	var total := 0.0
	var n := int(cfg.n)
	for e: Dictionary in sel.entries:
		var refs := _refs_for(e).size()
		var usd := _estimate(e, n, refs)
		total += usd
		print("  P%d %-28s %s ｜%s %s ×%d ≈$%.2f%s" % [int(e.priority), e.id, e.cn, StudioCore.api_size(str(e.ratio)),
			"透明底" if StudioCore.api_background(e) == "transparent" else "不透明", n, usd,
			("｜风格参考 %d 张" % refs) if refs > 0 else ""])
	for s: Dictionary in sel.skipped:
		print("  - 跳过 %s：%s" % [s.id, s.why])
	for u: String in sel.unknown:
		print("  ? 不认识：%s（用 anchor / p1 / p2 / p3 / all / redo 或资产 id）" % u)
	var count: int = (sel.entries as Array).size()
	print("预计：%d 项 × %d 张 = %d 张图，约 $%.2f（%s · %s 质量%s；实际以 OpenAI 账单为准）" % [count, n, count * n, total,
		cfg.model, cfg.quality, "" if StudioCore.price_known(str(cfg.model)) else " · 按 gpt-image-1 价格估算"])
	print("PLAN items=%d images=%d usd=%.2f" % [count, count * n, total])
	return total


func _cmd_plan() -> int:
	var info := _load_key()
	var sel := _selection()
	if sel.is_empty():
		print("用法：plan <anchor|p1|p2|p3|all|redo|资产id,...>")
		return 2
	if not info.found:
		print("  （还没有 GPTapi.txt：只是估算）")
	_print_plan(sel)
	return 0


func _cmd_gen() -> int:
	if not _require_key():
		return 3
	var lock := _live_gen_lock()
	if not lock.is_empty():
		print("x 另一个 gen 正在运行（%s 开始，选择：%s）。等它结束再生成（它结束时会有通知），否则同一批图会被付两次钱。" % [str(lock.get("started", "?")), str(lock.get("sel", ""))])
		return 5
	var sel := _selection()
	if sel.is_empty():
		print("用法：gen <anchor|p1|p2|p3|all|redo|资产id,...> [--max-usd X] [--total-usd Y]")
		return 2
	var total := _print_plan(sel)
	if (sel.entries as Array).is_empty():
		print("没有需要生成的资产。")
		return 0
	_run_cap = float(str(opts.get("max-usd", cfg.budget)).trim_prefix("$").trim_suffix("$"))
	if _run_cap <= 0.0 or _run_cap >= 10000.0:
		print("x --max-usd 要写成正数，单位美元，例如 --max-usd 5")
		return 2
	_total_cap = float(str(opts.get("total-usd", cfg.budget_total)).trim_prefix("$").trim_suffix("$"))
	var spent := float(state.get("spent_usd", 0.0))
	if _total_cap > 0.0:
		var left := _total_cap - spent
		if total > left + 0.005:
			print("x 用户给的总预算 $%.2f 已花 $%.2f，只剩 $%.2f，这批预计 $%.2f：先问用户要不要加预算（或者只生成一部分）。" % [_total_cap, spent, maxf(left, 0.0), total])
			return 4
		_run_cap = minf(_run_cap, left)
	if total > _run_cap + 0.005:
		print("x 预计 $%.2f 超过本次上限 $%.2f：先把费用告诉用户，用户同意后加 --max-usd %.2f 重跑（或者分批生成）。" % [total, _run_cap, ceilf(total * 1.1 * 100.0) / 100.0])
		return 4
	var started := _now()
	_gen_running = true
	_heartbeat(started)
	print("== 开始生成（%s，%d 路并发）" % [StudioCore.host_of(str(cfg.base_url)), int(cfg.concurrency)])
	_queue = (sel.entries as Array).duplicate()
	_workers_left = mini(int(cfg.concurrency), _queue.size())
	for i in _workers_left:
		_worker()
	while _workers_left > 0:
		await process_frame
	_save_state()
	_gen_running = false
	DirAccess.remove_absolute(art.path_join(".gen.lock"))
	print("")
	print("生成完成：成功 %d 项，失败 %d 项；本次约 $%.2f，累计 $%.2f" % [_gen_ok, _gen_failed, _run_spent, float(state.spent_usd)])
	if float(state.get("maybe_billed_usd", 0.0)) > 0.0:
		print("! 其中约 $%.2f 是超时或断线的请求：可能已经计费，但没有拿到图（已计入花费，宁多勿少）" % float(state.maybe_billed_usd))
	if _stopped_by_cap:
		print("! 达到本次上限 $%.2f，剩下的没有生成（再跑一次 gen 会接着做）" % _run_cap)
	if _fatal != "":
		print("x 已停止：" + _fatal)
	print("GEN ok=%d failed=%d usd=%.2f fatal=%s" % [_gen_ok, _gen_failed, _run_spent, "yes" if _fatal != "" else "no"])
	if _gen_ok > 0:
		print("next: Claude 初审 —— 逐个 Read 美术资产/候选/_对比/<id>.png（上排原图从左到右是第 1..n 张，下排是游戏处理后的样子），按 art-studio.md §4 打分，写 美术资产/初审.json，然后 art_studio.sh <W> apply")
	return 3 if _fatal != "" else 0


func _worker() -> void:
	while not _queue.is_empty() and _fatal == "":
		var e: Dictionary = _queue.pop_front()
		var est := _estimate(e, int(cfg.n), _refs_for(e).size())
		if _run_spent + _reserved + est > _run_cap * 1.05 + 0.005:  # in-flight requests count too
			_stopped_by_cap = true
			continue
		_reserved += est
		await _gen_one(e)
		_reserved -= est
	_workers_left -= 1


func _gen_one(e: Dictionary) -> void:
	var id: String = e.id
	var a := StudioCore.asset(state, id)
	var refs := _refs_for(e)
	var n := int(cfg.n)
	var size := StudioCore.api_size(str(e.ratio))
	var host := StudioCore.host_of(str(cfg.base_url))
	var est := StudioCore.estimate_usd(str(cfg.model), str(cfg.quality), size, n, refs.size(), 400)
	var resp := {}
	var body := {}
	var prompt := ""
	var attempt := 0
	var server_retries := 0
	while true:
		prompt = StudioCore.gpt_prompt(e, str(a.get("prompt", "")), not refs.is_empty(), not _dropped.has("background"))
		var params := {"model": str(cfg.model), "prompt": prompt, "n": n, "size": size, "quality": str(cfg.quality),
			"background": StudioCore.api_background(e), "output_format": "png"}
		if str(cfg.moderation) == "low" and refs.is_empty():  # /images/edits has no moderation parameter
			params["moderation"] = "low"
		for p: String in _dropped:
			params.erase(p)
		if refs.is_empty():
			var h := _auth()
			h.append("Content-Type: application/json")
			resp = await _http(HTTPClient.METHOD_POST, str(cfg.base_url) + "/images/generations", h, JSON.stringify(params).to_utf8_buffer())
		else:
			var mp := _multipart(params, refs)
			var h2 := _auth()
			h2.append("Content-Type: " + str(mp.type))
			resp = await _http(HTTPClient.METHOD_POST, str(cfg.base_url) + "/images/edits", h2, mp.body)
		body = _json_body(resp)
		a = StudioCore.asset(state, id)  # the state may have been merge-reloaded while we waited
		if int(resp.result) == HTTPRequest.RESULT_SUCCESS and int(resp.code) == 200 and body.get("data", null) is Array:
			break
		if _fatal != "":
			return
		var ex := _explain(resp, body)
		attempt += 1
		if ex.has("drop_param") and not _dropped.has(ex.drop_param):
			_dropped[str(ex.drop_param)] = true
			print("  ! %s" % ex.msg)
			continue
		if bool(ex.get("maybe_billed", false)):  # count it: better to over-report than to hide spend
			_add_spend(est, true)
		if bool(ex.fatal):
			_fatal = str(ex.msg)
			StudioCore.record_failed(state, id, str(ex.msg), _now())
			_touch(id)
			_gen_failed += 1
			_save_state()
			return
		var may_retry := bool(ex.retry) and attempt <= RETRY_WAIT.size()
		if bool(ex.get("server_error", false)):
			server_retries += 1
			may_retry = may_retry and server_retries <= 1
		if may_retry:
			var wait := _retry_after(resp)
			if wait < 0.0:
				wait = RETRY_WAIT[attempt - 1]
			print("  … %s：%s，%d 秒后重试（第 %d 次）" % [id, ex.msg, int(wait), attempt])
			await create_timer(wait).timeout
			continue
		StudioCore.record_failed(state, id, str(ex.msg), _now())
		_touch(id)
		_gen_failed += 1
		print("x %-28s %s" % [id, ex.msg])
		_save_state()
		return
	_had_success = true
	var gen_no := int(a.get("gens", 0)) + 1
	var files: Array = []
	var k := 0
	for d: Variant in body.data:
		if not d is Dictionary:
			continue
		var dd: Dictionary = d
		var bytes := PackedByteArray()
		if dd.has("b64_json") and str(dd.b64_json) != "":
			bytes = Marshalls.base64_to_raw(str(dd.b64_json))
		elif dd.has("url") and str(dd.url) != "":
			var dl := await _http(HTTPClient.METHOD_GET, str(dd.url), PackedStringArray(), PackedByteArray(), true)
			if int(dl.result) == HTTPRequest.RESULT_SUCCESS and int(dl.code) == 200:
				bytes = dl.body
		var ext := StudioCore.image_ext(bytes)
		if ext == "":
			continue
		k += 1
		var name := StudioCore.candidate_name(id, gen_no, k, ext)
		while FileAccess.file_exists(art.path_join("候选").path_join(name)) or FileAccess.file_exists(art.path_join("淘汰").path_join(name)):
			k += 1
			name = StudioCore.candidate_name(id, gen_no, k, ext)
		var f := FileAccess.open(art.path_join("候选").path_join(name), FileAccess.WRITE)
		f.store_buffer(bytes)
		f.close()
		files.append(name)
	est = StudioCore.estimate_usd(str(cfg.model), str(cfg.quality), size, maxi(files.size(), n), refs.size(), prompt.length())
	var usage: Dictionary = body.get("usage", {}) if body.get("usage", null) is Dictionary else {}
	var usd := StudioCore.usage_usd(str(cfg.model), usage, est)
	if files.is_empty():  # billed, but nothing usable came back
		_add_spend(usd, true)
		StudioCore.record_failed(state, id, "接口返回了成功，但里面没有图片", _now())
		_touch(id)
		_gen_failed += 1
		print("x %-28s 接口返回了成功，但里面没有图片" % id)
		_save_state()
		return
	_run_spent += usd
	_unsaved_spend += usd  # record_gen adds it to state.spent_usd
	var ref_names: Array = []
	for r: String in refs:
		ref_names.append(r.get_file())
	StudioCore.record_gen(state, id, files, prompt, usd, str(cfg.model), ref_names, _now())
	_touch(id)
	_save_state()
	var notes := _contact_sheet(e, files)
	_gen_ok += 1
	print("ok %-28s %d 张 → 候选/%s … ｜$%.3f%s" % [id, files.size(), files[0], usd, ("｜参考：" + ", ".join(PackedStringArray(ref_names))) if not ref_names.is_empty() else ""])
	for line: String in notes:
		print("    " + line)


func _multipart(fields: Dictionary, files: Array) -> Dictionary:
	var boundary := "----chimera%d%d" % [Time.get_ticks_usec(), randi() % 100000]
	var body := PackedByteArray()
	for k: String in fields:
		body.append_array(("--%s\r\nContent-Disposition: form-data; name=\"%s\"\r\n\r\n%s\r\n" % [boundary, k, str(fields[k])]).to_utf8_buffer())
	var i := 0
	for path: String in files:
		var img := _load_image(path)
		if img == null:
			continue
		if maxi(img.get_width(), img.get_height()) > 768:  # style only: a smaller ref is enough and cheaper
			var s := 768.0 / maxi(img.get_width(), img.get_height())
			img.resize(maxi(1, int(img.get_width() * s)), maxi(1, int(img.get_height() * s)), Image.INTERPOLATE_LANCZOS)
		i += 1
		body.append_array(("--%s\r\nContent-Disposition: form-data; name=\"image[]\"; filename=\"ref%d.png\"\r\nContent-Type: image/png\r\n\r\n" % [boundary, i]).to_utf8_buffer())
		body.append_array(img.save_png_to_buffer())
		body.append_array("\r\n".to_utf8_buffer())
	body.append_array(("--%s--\r\n" % boundary).to_utf8_buffer())
	return {"body": body, "type": "multipart/form-data; boundary=" + boundary}


static func _load_image(path: String) -> Image:
	var bytes := FileAccess.get_file_as_bytes(path)
	var img := Image.new()
	var err := ERR_FILE_UNRECOGNIZED
	match StudioCore.image_ext(bytes):
		"png":
			err = img.load_png_from_buffer(bytes)
		"jpg":
			err = img.load_jpg_from_buffer(bytes)
		"webp":
			err = img.load_webp_from_buffer(bytes)
	return img if err == OK and not img.is_empty() else null


## One PNG per asset for Claude's first pass: top row = raw candidates 1..n (left to right, n dots
## in each cell's corner), bottom row = what the game importer makes of each (cut out / grayscale /
## cropped) on a checkerboard. Returns importer warnings per candidate.
func _contact_sheet(e: Dictionary, files: Array) -> PackedStringArray:
	var notes: PackedStringArray = []
	var size := StudioCore.api_size(str(e.ratio))
	var cell := Vector2i(360, 360)
	if size == "1536x1024":
		cell = Vector2i(480, 320)
	elif size == "1024x1536":
		cell = Vector2i(260, 390)
	var pad := 14
	var sheet := Image.create(pad + files.size() * (cell.x + pad), pad * 3 + cell.y * 2, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#1d1924"))
	for i in files.size():
		var img := _load_image(art.path_join("候选").path_join(files[i]))
		var x := pad + i * (cell.x + pad)
		if img == null:
			notes.append("第 %d 张读不出来" % (i + 1))
			continue
		img.convert(Image.FORMAT_RGBA8)
		_blit_fit(sheet, img, Rect2i(x, pad, cell.x, cell.y))
		var res := ArtImporter.process(img, e)
		if res.has("image"):
			_blit_fit(sheet, res.image, Rect2i(x, pad * 2 + cell.y, cell.x, cell.y))
		for w: String in res.get("warnings", []):
			notes.append("第 %d 张：%s" % [i + 1, w])
		if res.has("error"):
			notes.append("第 %d 张：%s" % [i + 1, res.error])
		for d in i + 1:  # index dots
			sheet.fill_rect(Rect2i(x + 6 + d * 14, pad + 6, 10, 10), Color("#ffd166"))
	sheet.save_png(art.path_join("候选/_对比").path_join(str(e.id) + ".png"))
	return notes


static func _blit_fit(sheet: Image, src: Image, box: Rect2i) -> void:
	for yy in range(0, box.size.y, 16):  # checkerboard shows transparency
		for xx in range(0, box.size.x, 16):
			var c := Color("#3b3645") if ((xx + yy) / 16) % 2 == 0 else Color("#4b4556")
			sheet.fill_rect(Rect2i(box.position.x + xx, box.position.y + yy, mini(16, box.size.x - xx), mini(16, box.size.y - yy)), c)
	var img: Image = src.duplicate()
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	var k := minf(float(box.size.x) / img.get_width(), float(box.size.y) / img.get_height())
	var w := maxi(1, int(img.get_width() * k))
	var h := maxi(1, int(img.get_height() * k))
	img.resize(w, h, Image.INTERPOLATE_BILINEAR)
	sheet.blend_rect(img, Rect2i(0, 0, w, h), box.position + Vector2i((box.size.x - w) / 2, (box.size.y - h) / 2))


# ================================================================== apply (Claude's first pass)

func _cmd_apply() -> int:
	var p := art.path_join("初审.json")
	if not FileAccess.file_exists(p):
		print("没有 美术资产/初审.json。格式见 art-studio.md §4，例如：")
		print("  {\"part_sac\": {\"pick\": 2, \"alt\": 3, \"note\": \"描边闭合、灰度干净\"}, \"body_biped\": {\"redo\": \"头太小\", \"prompt\": \"完整新提示词（可选）\"}}")
		return 2
	var txt := StudioCore.decode_text(FileAccess.get_file_as_bytes(p))
	var json := JSON.new()
	if json.parse(txt) != OK or not json.data is Dictionary:
		print("x 初审.json 不是合法的 JSON 对象（第 %d 行：%s）。修好后重跑 apply。" % [json.get_error_line(), json.get_error_message()])
		return 2
	var verdicts: Dictionary = json.data
	var ok := 0
	var bad := 0
	var picks := 0
	var redos := 0
	for raw_id: String in verdicts:
		var id := raw_id.strip_edges().get_basename() if raw_id.ends_with(".png") else raw_id.strip_edges()
		if not by_id.has(id):
			print("x %s：不认识的资产 id" % raw_id)
			bad += 1
			continue
		if not verdicts[raw_id] is Dictionary:
			print("x %s：内容要是 {\"pick\": ...} 或 {\"redo\": ...} 或 {\"prompt\": ...}" % id)
			bad += 1
			continue
		var cands := _files_of("候选", id)
		var res := StudioCore.apply_verdict(state, id, verdicts[raw_id], cands, int(_cfg_quiet().max_rounds), _now())
		_touch(id)
		if not bool(res.ok):
			print("x %s：%s" % [id, res.msg])
			bad += 1
			continue
		for f: String in res.to_review:
			_move("候选", "待复审", f)
		for f: String in res.to_reject:
			_move("待复审" if bool(res.from_review) else "候选", "淘汰", f)
		if _files_of("候选", id).is_empty() and FileAccess.file_exists(art.path_join("候选/_对比").path_join(id + ".png")):
			DirAccess.remove_absolute(art.path_join("候选/_对比").path_join(id + ".png"))
		if not (res.to_review as Array).is_empty():
			picks += 1
		elif _status_of(id) == "claude_redo":
			redos += 1
		print("✓ %s：%s" % [id, res.msg])
		ok += 1
	_save_state()
	var dest := art.path_join(".history").path_join("初审_%s.json" % _now().replace(":", "").replace(" ", "_"))
	DirAccess.rename_absolute(p, dest)
	print("APPLY ok=%d failed=%d picks=%d redo=%d" % [ok, bad, picks, redos])
	if bad > 0:
		print("! 有 %d 项没应用：改好后只把这几项重新写进 初审.json 再 apply（这次的已存到 .history/）" % bad)
	if redos > 0:
		print("next: art_studio.sh <W> gen redo（重画 %d 项）" % redos)
	if picks > 0 or int(StudioCore.counts(state).user_review) > 0:
		print("next: art_studio.sh <W> trial（试装截图 + 审核页面），然后 art_studio.sh <W> serve 交给用户复审")
	return 0 if bad == 0 else 1


## Settings without requiring a valid key (apply/page/user-apply work offline).
func _cfg_quiet() -> Dictionary:
	if cfg.is_empty():
		_load_key()
	return cfg


# ================================================================== trial + page

func _cmd_trial_list() -> int:
	var n := 0
	for e: Dictionary in entries:
		if _status_of(e.id) != "user_review":
			continue
		var pick: String = str(StudioCore.asset(state, e.id).get("pick", ""))
		var path := art.path_join("待复审").path_join(pick)
		if pick != "" and FileAccess.file_exists(path):
			print("TRIAL\t%s\t%s" % [e.id, path])
			n += 1
	if n == 0:
		print("TRIAL_NONE")
	return 0


func _cmd_trial_done() -> int:
	var trial := str(opts.get("trial", "")).replace("\\", "/")
	var out := art.path_join("待复审/试装")
	for e: Dictionary in entries:
		var dst := out.path_join(str(e.id) + ".png")
		if _status_of(e.id) != "user_review":
			if FileAccess.file_exists(dst):
				DirAccess.remove_absolute(dst)
			continue
		var src := trial.path_join(str(e.path).trim_prefix("res://"))
		if trial != "" and FileAccess.file_exists(src):
			DirAccess.copy_absolute(src, dst)
		elif FileAccess.file_exists(dst):
			DirAccess.remove_absolute(dst)
	return _build_page()


func _build_page() -> int:
	var sig := StudioCore.review_signature(state)
	if sig != str(state.get("page_sig", "")) or int(state.get("batch", 0)) == 0:
		_set_key("batch", int(state.get("batch", 0)) + 1)  # same set of images -> same batch (keeps browser drafts)
		_set_key("page_sig", sig)
	_set_key("page_built_unix", int(Time.get_unix_time_from_system()))
	var processed := {}
	var screens := {}
	for e: Dictionary in entries:
		if FileAccess.file_exists(art.path_join("待复审/试装").path_join(str(e.id) + ".png")):
			processed[e.id] = "待复审/试装/%s.png" % e.id
	for s: String in SCREENS:
		if FileAccess.file_exists(art.path_join("待复审/试装").path_join(s + ".png")):
			screens[s] = "待复审/试装/%s.png" % s
	var data := StudioCore.page_data(entries, state, _present(), processed, screens, str(_cfg_quiet().model), _now())
	var tpl := FileAccess.get_file_as_string("res://tools/review_page.html")
	if not tpl.contains("/*__REVIEW_DATA__*/null"):
		printerr("tools/review_page.html is missing the /*__REVIEW_DATA__*/null placeholder")
		return 1
	# "<" only occurs inside JSON strings; \u003c keeps "</script>" and "<!--" from ending the script block
	var json := JSON.stringify(data).replace("<", "\\u003c")
	var f := FileAccess.open(art.path_join("审核页面.html"), FileAccess.WRITE)
	f.store_string(tpl.replace("/*__REVIEW_DATA__*/null", json))
	f.close()
	_save_state()
	var n: int = (data.items as Array).size()
	print("审核页面：%s（第 %d 批，%d 项待复审）" % [art.path_join("审核页面.html"), int(state.batch), n])
	print("PAGE items=%d batch=%d" % [n, int(state.batch)])
	if n > 0:
		print("next: art_studio.sh <W> serve（用 run_in_background 后台运行；会自动打开用户浏览器，用户提交后进程自己结束）")
	return 0


# ================================================================== user-apply

## Newest review result: --file, 美术资产/复审结果.json (written by the review server), or a
## 复审结果*.json in the workspace / the browser's Downloads folder that is newer than the current
## review page and than the last applied result (old downloads from other projects never count).
func _find_result_file() -> String:
	if opts.has("file"):
		var fp := str(opts.file).replace("\\", "/")
		if fp.is_relative_path() and not (fp.length() > 1 and fp[1] == ":"):
			fp = ws.path_join(fp)
		return fp
	var p := art.path_join("复审结果.json")
	if FileAccess.file_exists(p):
		return p
	if int(state.get("page_built_unix", 0)) == 0:
		return ""  # no review page was ever built in this workspace
	var best := ""
	var best_t := maxi(int(state.get("last_result_mtime", 0)), int(state.get("page_built_unix", 0)))
	var dirs: Array = [art, ws]
	var dl := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	if dl != "":
		dirs.append(dl)
	for d: String in dirs:
		if not DirAccess.dir_exists_absolute(d):
			continue
		for f in DirAccess.get_files_at(d):
			if f.begins_with("复审结果") and f.ends_with(".json"):
				var t := FileAccess.get_modified_time(d.path_join(f))
				if t > best_t:
					best_t = t
					best = d.path_join(f)
	return best


func _cmd_user_apply() -> int:
	var p := _find_result_file()
	if p == "" or not FileAccess.file_exists(p):
		print("没有找到 复审结果.json：用户提交后它会出现在 美术资产/（用服务器提交时）或浏览器的下载文件夹。")
		print("用户也可能把结果直接贴在聊天里：把那段 JSON 存成 美术资产/复审结果.json 再运行 user-apply。")
		return 2
	var json := JSON.new()
	if json.parse(StudioCore.decode_text(FileAccess.get_file_as_bytes(p))) != OK or not json.data is Dictionary \
			or not (json.data as Dictionary).get("items", null) is Dictionary:
		print("x %s 不是有效的复审结果（需要 {\"items\": {...}}）" % p)
		return 2
	var result: Dictionary = json.data
	var items: Dictionary = result.items
	var approved: Array = []
	var rejected: Array = []
	var ignored := 0
	var available: Array = Array(DirAccess.get_files_at(art.path_join("待复审")))
	var same_batch := int(result.get("batch", -1)) == int(state.get("batch", 0))
	for id: String in items:
		if not by_id.has(id) or not items[id] is Dictionary:
			ignored += 1
			continue
		var res := StudioCore.apply_user(state, id, items[id], _now(), available, same_batch)
		_touch(id)
		if not bool(res.ok):
			print("- %s：%s" % [id, res.msg])
			ignored += 1
			continue
		for f: String in res.reject:
			_move("待复审", "淘汰", f)
		if str(res.approve) != "":
			_approve_file(id, str(res.approve))
			approved.append(id)
		else:
			rejected.append(id)
	_set_key("last_result_mtime", FileAccess.get_modified_time(p))
	_save_state()
	var dest := art.path_join(".history").path_join("复审结果_%d_%s.json" % [int(result.get("batch", 0)), _now().replace(":", "").replace(" ", "_")])
	if p.begins_with(art) or p.begins_with(ws):
		DirAccess.rename_absolute(p, dest)
	else:
		DirAccess.copy_absolute(p, dest)  # the browser's Downloads folder: leave the user's file alone
	for e: Dictionary in entries:  # stale trial previews of decided assets
		var tp := art.path_join("待复审/试装").path_join(str(e.id) + ".png")
		if FileAccess.file_exists(tp) and _status_of(e.id) != "user_review":
			DirAccess.remove_absolute(tp)
	print("复审：通过 %d 项，不要 %d 项，忽略 %d 项" % [approved.size(), rejected.size(), ignored])
	for id: String in approved:
		print("APPROVED\t%s" % id)
	for id: String in rejected:
		print("REJECTED\t%s\t%s" % [id, str(StudioCore.asset(state, id).get("user_comment", ""))])
	print("USER approved=%d rejected=%d pending=%d" % [approved.size(), rejected.size(), int(StudioCore.counts(state).user_review)])
	if not approved.is_empty():
		print("next: art_studio.sh <W> sync（把通过的图导入游戏）")
	if not rejected.is_empty():
		print("next: 按用户意见改提示词：写 美术资产/初审.json {\"<id>\": {\"prompt\": \"完整新提示词\"}} → apply → plan redo → gen redo")
	return 0


## Moves the approved original to 已通过/<id>.<ext>; an older approved version goes to 淘汰/.
func _approve_file(id: String, name: String) -> void:
	var src := art.path_join("待复审").path_join(name)
	if not FileAccess.file_exists(src):
		print("  ! %s：找不到 待复审/%s（被手动挪走了？）" % [id, name])
		return
	var dir := art.path_join("已通过")
	for f in DirAccess.get_files_at(dir):
		if f.get_basename() == id:
			var old := "%s__old_%s.%s" % [id, _now().replace(":", "").replace(" ", "_").replace("-", ""), f.get_extension()]
			DirAccess.rename_absolute(dir.path_join(f), art.path_join("淘汰").path_join(old))
	var dst := dir.path_join("%s.%s" % [id, name.get_extension()])
	DirAccess.rename_absolute(src, dst)
	StudioCore.asset(state, id)["approved_md5"] = FileAccess.get_md5(dst)
	_touch(id)


# ================================================================== sync

## 已通过/ files that are not (or no longer) in the game: {file: md5}. Checks the game itself (the
## asset exists and its sidecar's source_md5 matches), so a recreated or git-reset game gets its
## approved art back; unknown names fall back to the record of what was copied.
func _unsynced() -> Dictionary:
	var out := {}
	var imported: Dictionary = state.get("imported", {})
	for f in DirAccess.get_files_at(art.path_join("已通过")):
		if not IMG_EXTS.has(f.get_extension().to_lower()):
			continue
		var md5 := FileAccess.get_md5(art.path_join("已通过").path_join(f))
		var id := f.get_basename()
		if by_id.has(id):
			var entry: Dictionary = by_id[id]
			var meta_path := ProjectSettings.globalize_path(str(entry.path).get_basename() + ".json")
			var game_md5 := ""
			if FileAccess.file_exists(meta_path):
				var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
				if v is Dictionary:
					game_md5 = str((v as Dictionary).get("source_md5", ""))
			if not ArtManifest.is_present(entry):
				out[f] = md5  # missing from the game (recreated, git reset): bring it back
			elif game_md5 != md5 and str(imported.get(f, "")) != md5:
				out[f] = md5  # new approved version; a later manual replacement of synced art is left alone
		elif str(imported.get(f, "")) != md5:
			out[f] = md5
	return out


func _cmd_sync_prepare() -> int:
	var inbox := ProjectSettings.globalize_path("res://art_inbox")
	DirAccess.make_dir_recursive_absolute(inbox)
	var todo := _unsynced()
	var credits := {}
	var cj := inbox.path_join("credits.json")
	if FileAccess.file_exists(cj):
		var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(cj))
		if v is Dictionary:
			credits = v
	var manual := _manual_credit()
	var n := 0
	for f: String in todo:
		var id := f.get_basename()
		var a: Dictionary = (state.assets as Dictionary).get(id, {})
		DirAccess.copy_absolute(art.path_join("已通过").path_join(f), inbox.path_join(f))
		if str(a.get("source", "")) == "gpt" and str(a.get("approved_md5", "")) == str(todo[f]):
			credits[f] = "OpenAI %s（AI 生成；Claude 初审，作者复审通过）" % str(a.get("model", "gpt-image-1"))
		elif manual != "":
			credits[f] = manual
		else:
			credits.erase(f)
		(state.imported as Dictionary)[f] = todo[f]
		_dirty_imported[f] = true
		n += 1
		print("  → art_inbox/%s" % f)
	if n > 0:
		var w := FileAccess.open(cj, FileAccess.WRITE)
		w.store_string(JSON.stringify(credits, "  "))
		w.close()
	_save_state()
	print("SYNC %d" % n)
	return 0


## Credit line for the user's own images in 已通过/: last line of 美术资产/credits.txt.
func _manual_credit() -> String:
	var p := art.path_join("credits.txt")
	if not FileAccess.file_exists(p):
		return ""
	var last := ""
	for l in StudioCore.decode_text(FileAccess.get_file_as_bytes(p)).replace("\r", "").split("\n"):
		if l.strip_edges() != "":
			last = l.strip_edges()
	return last
