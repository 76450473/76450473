class_name StudioCore
extends RefCounted
## Pure rules of the art studio: GPT image generation + Claude first pass + user review.
## No file or network I/O here (that lives in tools/art_studio.gd), so every rule is unit-tested
## in tests/test_art_studio.gd. Workspace layout and protocols: references/art-studio.md.
##
## Asset life cycle (记录.json "assets"[id].status):
##   (none) --gen--> candidates --Claude pick--> user_review --user approve--> approved
##                       |                            |
##                       +--Claude redo--> claude_redo +--user reject--> user_rejected
##   claude_redo / user_rejected / failed --gen--> candidates (a new round)

const DEFAULTS := {
	"base_url": "https://api.openai.com/v1", "model": "gpt-image-1", "quality": "medium", "n": 3,
	"budget": 3.0, "style_ref": "auto", "moderation": "auto", "proxy": "", "concurrency": 2,
	"max_rounds": 3, "timeout": 300, "budget_total": 0.0,
}
const SETTING_KEYS := ["base_url", "model", "quality", "n", "budget", "budget_total", "style_ref", "moderation",
	"proxy", "concurrency", "max_rounds", "timeout"]
const KEY_NAMES := ["key", "api_key", "apikey", "openai_api_key", "token"]
## Output image tokens per image: [square, non-square] (OpenAI gpt-image-1 docs, 2025).
const OUT_TOKENS := {"low": [272, 408], "medium": [1056, 1584], "high": [4160, 6240]}
## USD per 1M tokens. Unknown models are estimated with gpt-image-1 prices.
const PRICES := {
	"gpt-image-1": {"text_in": 5.0, "image_in": 10.0, "out": 40.0},
	"gpt-image-1-mini": {"text_in": 2.0, "image_in": 2.5, "out": 8.0},
}
const REF_IMAGE_TOKENS := 1500
## Background phrases of data/art_manifest.json prompts, longest first.
const BG_PHRASES := ["plain flat pure white background", "plain flat pure black background",
	"flat pure white background", "flat pure black background", "pure white background", "pure black background"]
const TRANSPARENT_BG := "fully transparent background (real alpha channel, no backdrop at all)"
const REF_PREFIX := "Use the attached reference image(s) ONLY as a style guide: line weight, shading, value range and level of detail. Do not copy their subject, pose or composition. Draw this new subject: "
const CATEGORY_CN := {"body": "骨架", "part": "部件", "background": "背景", "icon": "图标", "ui": "界面",
	"boss": "Boss", "card_art": "卡图"}
const SCREEN_OF := {"body": "art_gallery", "icon": "art_gallery", "part": "art_parts", "background": "art_images",
	"ui": "art_images", "boss": "art_images", "card_art": "art_images"}


# ------------------------------------------------------------------ key file

## Decodes GPTapi.txt bytes: UTF-8 (BOM optional) or UTF-16 with BOM (Notepad "Unicode").
static func decode_text(bytes: PackedByteArray) -> String:
	if bytes.size() >= 2 and bytes[0] == 0xFF and bytes[1] == 0xFE:
		return bytes.slice(2).get_string_from_utf16()
	if bytes.size() >= 2 and bytes[0] == 0xFE and bytes[1] == 0xFF:
		var swapped := bytes.slice(2)
		for i in range(0, swapped.size() - 1, 2):
			var t := swapped[i]
			swapped[i] = swapped[i + 1]
			swapped[i + 1] = t
		return swapped.get_string_from_utf16()
	if bytes.size() >= 3 and bytes[0] == 0xEF and bytes[1] == 0xBB and bytes[2] == 0xBF:
		return bytes.slice(3).get_string_from_utf8()
	return bytes.get_string_from_utf8()


## GPTapi.txt -> {"key": String, "settings": Dictionary, "errors": PackedStringArray, "warnings": PackedStringArray}.
## The first plain line is the key; optional "name=value" lines are settings (see DEFAULTS).
static func parse_key_file(text: String) -> Dictionary:
	var key := ""
	var settings := {}
	var errors: PackedStringArray = []
	var warnings: PackedStringArray = []
	var line_no := 0
	text = text.replace("﻿", "").replace("\r", "\n").replace("　", " ")
	for raw: String in text.split("\n"):
		var line := raw.strip_edges()
		if line == "" or line.begins_with("#") or line.begins_with("//"):
			continue
		line_no += 1
		var eq := -1
		for sep: String in ["=", "：", ":"]:  # "key=sk-..", "key：sk-.." (Chinese IME), "model: x"
			var i := line.find(sep)
			if i <= 0:
				continue
			var nm := line.substr(0, i).strip_edges().to_lower()
			if KEY_NAMES.has(nm) or SETTING_KEYS.has(nm):  # only known names: a token like "abc==" stays a key
				eq = i
				break
		if eq > 0:
			var name := line.substr(0, eq).strip_edges().to_lower()
			var value := _unquote(line.substr(eq + 1).strip_edges())
			if KEY_NAMES.has(name):
				key = value
			else:
				settings[name] = value
		elif key == "":
			key = _unquote(line)
		else:  # never echo the line: it may be a second key
			warnings.append("GPTapi.txt 第 %d 个非空行看不懂，已忽略（设置要写成 名字=值，例如 proxy=http://127.0.0.1:7890）" % line_no)
	if key.begins_with("Bearer "):
		key = key.substr(7).strip_edges()
	var key_err := check_key(key)
	if key_err != "":
		errors.append(key_err)
	elif not key.begins_with("sk-"):
		warnings.append("Key 不是以 sk- 开头：如果用的是中转服务的 Key，记得在 GPTapi.txt 加一行 base_url=中转地址")
	var clean := {}
	for k: String in settings:
		var res := _check_setting(k, str(settings[k]))
		if res.has("error"):
			errors.append(str(res.error))
		else:
			clean[k] = res.value
	return {"key": key, "settings": clean, "errors": errors, "warnings": warnings}


## Removes the key (and anything that looks like an OpenAI-style key) from text that came from the
## network, so relay error pages that echo the Authorization header never reach logs or 记录.json.
static func redact(text: String, key: String) -> String:
	var out := text
	if key.length() >= 8:
		out = out.replace(key, "sk-…" + key.right(4)).replace(key.to_lower(), "sk-…" + key.right(4))
	var re := RegEx.new()
	re.compile("(sk-|Bearer\\s+)[A-Za-z0-9_\\-]{12,}")
	return re.sub(out, "$1…(已隐藏)", true)


## "" when the key looks usable, otherwise a Chinese explanation (never echoes the key).
static func check_key(key: String) -> String:
	if key == "":
		return "GPTapi.txt 是空的：第一行写上 OpenAI 的 Key（sk- 开头那一串）"
	if key.length() < 20:
		return "GPTapi.txt 里的 Key 太短（%d 个字符），可能没复制完整" % key.length()
	for i in key.length():
		var c := key.unicode_at(i)
		if c <= 32 or c >= 127:
			return "GPTapi.txt 里的 Key 含有空格、中文或特殊字符：只保留 sk- 开头的那一串"
	return ""


static func _unquote(s: String) -> String:
	if s.length() >= 2 and ((s.begins_with("\"") and s.ends_with("\"")) or (s.begins_with("'") and s.ends_with("'"))):
		return s.substr(1, s.length() - 2).strip_edges()
	return s


static func _check_setting(k: String, v: String) -> Dictionary:
	match k:
		"quality":
			if ["low", "medium", "high"].has(v.to_lower()):
				return {"value": v.to_lower()}
			return {"error": "quality 只能是 low / medium / high（auto 会让费用无法预估，不支持）"}
		"n":
			if v.is_valid_int() and int(v) >= 1 and int(v) <= 8:
				return {"value": int(v)}
			return {"error": "n（每张资产的候选数）要在 1–8 之间"}
		"concurrency":
			if v.is_valid_int() and int(v) >= 1 and int(v) <= 4:
				return {"value": int(v)}
			return {"error": "concurrency 要在 1–4 之间"}
		"max_rounds":
			if v.is_valid_int() and int(v) >= 1 and int(v) <= 6:
				return {"value": int(v)}
			return {"error": "max_rounds 要在 1–6 之间"}
		"timeout":
			if v.is_valid_int() and int(v) >= 30:
				return {"value": int(v)}
			return {"error": "timeout 至少 30（秒）"}
		"budget", "budget_total":
			var b := v.trim_prefix("$").trim_suffix("$").trim_suffix("美元").trim_suffix("刀").strip_edges()
			if b.is_valid_float() and float(b) > 0.0 and float(b) < 10000.0:
				return {"value": float(b)}
			return {"error": "%s 要写成数字，单位美元，例如 %s=5" % [k, k]}
		"style_ref":
			if ["auto", "off", "on"].has(v.to_lower()):
				return {"value": "off" if v.to_lower() == "off" else "auto"}
			return {"error": "style_ref 只能是 auto 或 off"}
		"moderation":
			if ["auto", "low"].has(v.to_lower()):
				return {"value": v.to_lower()}
			return {"error": "moderation 只能是 auto 或 low"}
		"base_url":
			if v.begins_with("http://") or v.begins_with("https://"):
				var u := v.trim_suffix("/")
				if not u.ends_with("/v1") and not u.contains("/v1/") and u.count("/") <= 2:
					u += "/v1"  # "https://relay.example.com" -> ".../v1"
				return {"value": u}
			return {"error": "base_url 要以 http:// 或 https:// 开头"}
		"proxy":
			if parse_proxy(v).is_empty():
				return {"error": "proxy 写成 http://127.0.0.1:7890 这种格式（地址:端口）"}
			return {"value": v}
		"model":
			if v != "" and not v.contains(" "):
				return {"value": v}
			return {"error": "model 写错了，例如 model=gpt-image-1"}
	return {"value": v}


## Merges defaults <- GPTapi.txt settings <- explicit overrides (command-line flags).
## env: {"HTTPS_PROXY": ..} etc., used only when no proxy= line is given.
static func effective_settings(file_settings: Dictionary, overrides: Dictionary, env: Dictionary) -> Dictionary:
	var s := DEFAULTS.duplicate()
	for k: String in file_settings:
		s[k] = file_settings[k]
	for k: String in overrides:
		s[k] = overrides[k]
	if str(s.proxy) == "":
		for name: String in ["HTTPS_PROXY", "https_proxy", "ALL_PROXY", "all_proxy", "HTTP_PROXY", "http_proxy"]:
			var v: String = str(env.get(name, ""))
			if v != "" and not parse_proxy(v).is_empty():
				s.proxy = v
				break
	return s


## "http://127.0.0.1:7890" / "127.0.0.1:7890" / "socks5://h:1080" -> {"host", "port"} ({} if invalid or socks).
static func parse_proxy(url: String) -> Dictionary:
	var u := url.strip_edges()
	if u.begins_with("socks"):
		return {}
	u = u.trim_prefix("http://").trim_prefix("https://")
	var at := u.rfind("@")
	if at >= 0:
		u = u.substr(at + 1)
	u = u.get_slice("/", 0)
	var colon := u.rfind(":")
	if colon <= 0:
		return {}
	var port := u.substr(colon + 1)
	if not port.is_valid_int() or int(port) <= 0 or int(port) > 65535:
		return {}
	return {"host": u.substr(0, colon), "port": int(port)}


## False for loopback hosts and hosts matched by NO_PROXY ("localhost,.corp.example,*").
static func should_proxy(host: String, no_proxy: String) -> bool:
	var h := host.to_lower()
	if h.begins_with("["):
		return not h.begins_with("[::1]")
	h = h.get_slice(":", 0)
	if h == "localhost" or h.begins_with("127.") or h == "0.0.0.0":
		return false
	for raw: String in no_proxy.split(",", false):
		var p := raw.strip_edges().to_lower()
		if p == "*":
			return false
		p = p.trim_prefix("*").trim_prefix(".")
		if p != "" and (h == p or h.ends_with("." + p)):
			return false
	return true


## Host part of a base URL, for error messages ("api.openai.com").
static func host_of(url: String) -> String:
	return url.trim_prefix("https://").trim_prefix("http://").get_slice("/", 0)


# ------------------------------------------------------------------ request shaping

## Closest size the Images API supports for a manifest ratio ("16:9" -> "1536x1024").
static func api_size(ratio: String) -> String:
	var parts := ratio.split(":")
	if parts.size() != 2 or float(parts[1]) <= 0.0:
		return "1024x1024"
	var r := float(parts[0]) / float(parts[1])
	if r > 1.15:
		return "1536x1024"
	if r < 0.87:
		return "1024x1536"
	return "1024x1024"


## Cut-out style assets (parts, bodies, bosses) are requested with real transparency: cleaner
## edges than flood-filling a white backdrop. Icons keep their black backdrop because the mono
## importer keys on luminance there, which preserves holes inside a symbol; hollow frames keep
## the white fill their importer expects.
static func api_background(entry: Dictionary) -> String:
	var mode: String = entry.get("mode", "palette")
	if ["palette", "cutout"].has(mode) and not bool(entry.get("hollow", false)):
		return "transparent"
	return "opaque"


## The manifest prompt adapted for GPT: transparent backdrop, crop hint, style-reference
## preamble, negatives folded into an "Avoid:" sentence (the API has no negative prompt).
static func gpt_prompt(entry: Dictionary, override: String, with_refs: bool, alpha_ok: bool = true) -> String:
	var p := override.strip_edges() if override.strip_edges() != "" else str(entry.get("prompt", ""))
	if alpha_ok and api_background(entry) == "transparent":
		for phrase: String in BG_PHRASES:
			p = p.replace(phrase, TRANSPARENT_BG)
	if str(entry.get("fit", "fit")) == "cover":
		match str(entry.get("ratio", "1:1")):
			"16:9":
				p += " Compose for a 16:9 crop: keep everything important away from the top and bottom edges."
			"3:1":
				p += " Compose for a wide 3:1 crop: the element spans the full width and stays inside the middle third of the image height."
			"4:3":
				p += " Compose for a 4:3 crop: keep everything important away from the left and right edges."
			"5:7":
				p += " Compose for a 5:7 crop: keep everything important away from the top and bottom edges."
	if with_refs:
		p = REF_PREFIX + p
	var neg := str(entry.get("negative", "")).strip_edges()
	if neg != "" and not p.contains("Avoid:"):
		p += "\nAvoid: " + neg + "."
	return p


## Style-reference group of an asset: refs are only taken from the same group.
static func ref_group(entry: Dictionary) -> String:
	if bool(entry.get("enemy", false)):
		return "villain"  # villains only learn from villains, so heroine references never make them cute
	match str(entry.get("category", "")):
		"part", "body":
			return "creature"
		"icon":
			return "icon"
	return ""  # scenes, cards, UI, bosses: references would leak composition


## Up to `limit` approved files usable as style references for `entry`.
## approved: {asset_id: file_name}; anchors first, then alphabetical; never the asset itself.
static func pick_refs(entry: Dictionary, approved: Dictionary, entries_by_id: Dictionary, anchors: Array, limit: int) -> Array:
	var group := ref_group(entry)
	if group == "":
		return []
	var ids: Array = []
	for id: String in anchors:
		if approved.has(id) and not ids.has(id):
			ids.append(id)
	var rest: Array = approved.keys()
	rest.sort()
	for id: String in rest:
		if not ids.has(id):
			ids.append(id)
	var out: Array = []
	for id: String in ids:
		if id == str(entry.id) or not entries_by_id.has(id):
			continue
		if ref_group(entries_by_id[id]) == group:
			out.append(approved[id])
		if out.size() >= limit:
			break
	return out


# ------------------------------------------------------------------ money

static func _num(v: Variant) -> float:
	return float(v) if (v is int or v is float) else 0.0


static func price_known(model: String) -> bool:
	return PRICES.has(model)


static func _prices(model: String) -> Dictionary:
	return PRICES.get(model, PRICES["gpt-image-1"])


## Estimated USD for one request of n images (+ style references).
static func estimate_usd(model: String, quality: String, size: String, n: int, refs: int, prompt_chars: int) -> float:
	var q := quality if OUT_TOKENS.has(quality) else "medium"
	var out_tok: int = (OUT_TOKENS[q] as Array)[0 if size == "1024x1024" else 1]
	var pr := _prices(model)
	var usd := float(out_tok * n) * float(pr.out) / 1e6
	usd += float(prompt_chars / 4 + 20) * float(pr.text_in) / 1e6
	usd += float(refs * REF_IMAGE_TOKENS) * float(pr.image_in) / 1e6
	return usd


## Actual USD from the API's usage block; falls back to `fallback` when the relay sends none.
static func usage_usd(model: String, usage: Dictionary, fallback: float) -> float:
	var out_v: Variant = usage.get("output_tokens", null)
	if not (out_v is int or out_v is float) or float(out_v) <= 0.0:
		return fallback  # relays often send zeros, nulls or strings
	for k: String in ["input_tokens"]:
		if not (usage.get(k, 0) is int or usage.get(k, 0) is float):
			return fallback
	var pr := _prices(model)
	var details: Dictionary = usage.get("input_tokens_details", {}) if usage.get("input_tokens_details", null) is Dictionary else {}
	var text_in := _num(details.get("text_tokens", usage.get("input_tokens", 0)))
	var image_in := _num(details.get("image_tokens", 0))
	return (text_in * float(pr.text_in) + image_in * float(pr.image_in) + float(usage.output_tokens) * float(pr.out)) / 1e6


# ------------------------------------------------------------------ selection

## Which assets a "plan"/"gen" selection means.
## sel: tokens separated by commas/spaces: anchor | p1 | p2 | p3 | all | redo | <asset id>[.png]
## present: {id: true} for assets the game already has (imported art).
## Returns {"entries": [entry...], "skipped": [{"id", "why"}], "unknown": [token...]}.
static func select(entries: Array, sel: String, assets: Dictionary, anchors: Array, present: Dictionary,
		again: bool, max_rounds: int) -> Dictionary:
	var by_id := {}
	for e: Dictionary in entries:
		by_id[e.id] = e
	var wanted: Array = []
	var explicit := {}
	var unknown: Array = []
	for raw: String in sel.replace(",", " ").replace("，", " ").split(" ", false):
		var t := raw.strip_edges().to_lower()
		var ids: Array = []
		match t:
			"anchor", "定调", "定调批":
				ids = anchors.duplicate()
			"p1", "p2", "p3":
				for e: Dictionary in entries:
					if int(e.priority) == int(t.substr(1)):
						ids.append(e.id)
			"all", "全部":
				for e: Dictionary in entries:
					ids.append(e.id)
			"redo", "重做":
				for e: Dictionary in entries:
					var st: String = str((assets.get(e.id, {}) as Dictionary).get("status", ""))
					if ["claude_redo", "user_rejected", "failed"].has(st):
						ids.append(e.id)
			_:
				var id := t.get_basename() if t.ends_with(".png") else t
				if by_id.has(id):
					ids.append(id)
					explicit[id] = true
				else:
					unknown.append(raw)
		for id: String in ids:
			if by_id.has(id) and not wanted.has(id):
				wanted.append(id)
	var out: Array = []
	var skipped: Array = []
	for e: Dictionary in entries:  # keep manifest (priority) order
		if not wanted.has(e.id):
			continue
		var a: Dictionary = assets.get(e.id, {})
		var st: String = str(a.get("status", ""))
		var forced := again or explicit.has(e.id)
		var why := ""
		match st:
			"candidates":
				why = "已有候选，等 Claude 初审（候选/）"
			"user_review":
				why = "等你复审（审核页面）"
			"approved":
				why = "" if forced else "已通过"
			"claude_redo":
				if int(a.get("round", 0)) >= max_rounds and not forced:
					why = "已经生成 %d 轮：请从现有图里挑最好的交给用户复审" % int(a.get("round", 0))
			"user_rejected":
				if not bool(a.get("prompt_after_reject", false)) and not forced:
					why = "用户退回了，但还没按意见改提示词：先在 初审.json 写 {\"prompt\": ...} 再重画"
			"":
				if present.has(e.id) and not forced:
					why = "游戏里已经有这张图（之前导入的）；要重画请点名这个 id"
		if why != "":
			skipped.append({"id": e.id, "why": why})
		else:
			out.append(e)
	return {"entries": out, "skipped": skipped, "unknown": unknown}


# ------------------------------------------------------------------ state transitions

static func new_state() -> Dictionary:
	return {"version": 1, "batch": 0, "spent_usd": 0.0, "assets": {}, "imported": {}}


static func asset(state: Dictionary, id: String) -> Dictionary:
	var assets: Dictionary = state.get("assets", {})
	if not assets.has(id):
		assets[id] = {"status": "", "round": 0, "prompt": "", "history": []}
		state["assets"] = assets
	return assets[id]


static func _log(a: Dictionary, now: String, event: Dictionary) -> void:
	event["t"] = now
	var h: Array = a.get("history", [])
	h.append(event)
	a["history"] = h


## A generation round finished for `id`: candidates saved as `files` (names inside 候选/).
## Round number the next generation of this asset gets (a user rejection or a re-do of an
## approved asset starts a fresh review cycle at round 1).
static func next_round(a: Dictionary) -> int:
	if ["user_rejected", "approved", ""].has(str(a.get("status", ""))):
		return 1
	return int(a.get("round", 0)) + 1


static func record_gen(state: Dictionary, id: String, files: Array, prompt: String, usd: float, model: String,
		refs: Array, now: String) -> void:
	var a := asset(state, id)
	a["round"] = next_round(a)
	a["gens"] = int(a.get("gens", 0)) + 1  # total generations: names files, never resets
	a["status"] = "candidates"
	a["source"] = "gpt"
	a["model"] = model
	a["candidates"] = files.duplicate()
	state["spent_usd"] = snappedf(float(state.get("spent_usd", 0.0)) + usd, 0.0001)
	_log(a, now, {"event": "gen", "round": a.round, "files": files.duplicate(), "usd": snappedf(usd, 0.0001),
		"model": model, "refs": refs.duplicate(), "prompt": prompt})


static func record_failed(state: Dictionary, id: String, reason: String, now: String) -> void:
	var a := asset(state, id)
	if str(a.status) == "":  # approved / rejected / redo / pending reviews keep their meaning
		a["status"] = "failed"
	a["last_error"] = reason
	_log(a, now, {"event": "gen_failed", "reason": reason})


## Claude's first-pass verdict for one asset (an entry of 初审.json). `candidates` = file names of
## this asset currently in 候选/ (sorted). Returns {"ok", "msg", "to_review": [names], "to_reject": [names]}.
## verdict: {"pick": name|index, "alt"?: name|index, "note"?: str} | {"redo": reason, "prompt"?: str} | {"prompt": str}
## While the asset waits for the user: {"redo": reason} withdraws the pick, {"note": str} rewrites the note.
## "from_review" = the files to reject are in 待复审/ (not 候选/).
static func apply_verdict(state: Dictionary, id: String, verdict: Dictionary, candidates: Array, max_rounds: int,
		now: String) -> Dictionary:
	var a := asset(state, id)
	var st: String = str(a.status)
	var res := {"ok": false, "msg": "", "to_review": [], "to_reject": [], "from_review": false}
	var has_pick := verdict.has("pick") and str(verdict.pick) != ""
	var has_redo := verdict.has("redo") and str(verdict.redo) != "" and str(verdict.redo) != "false"
	var new_prompt := str(verdict.get("prompt", "")).strip_edges()
	if has_pick and has_redo:
		res.msg = "同时写了 pick 和 redo：二选一"
		return res
	if st == "user_review" and not has_pick:
		# after looking at the trial screenshots Claude may withdraw a pick or refine its note
		if has_redo:
			if int(a.get("round", 0)) >= max_rounds:
				res.msg = "已经生成 %d 轮（上限 %d）：不再自动重画，把问题写进 note 交给用户决定" % [int(a.round), max_rounds]
				return res
			for f: String in [str(a.get("pick", "")), str(a.get("alt", ""))]:
				if f != "":
					res.to_reject.append(f)
			res.from_review = true
			a["status"] = "claude_redo"
			a["claude_note"] = str(verdict.redo)
			a["pick"] = ""
			a["alt"] = ""
			if new_prompt != "":
				a["prompt"] = new_prompt
			_log(a, now, {"event": "claude_withdraw", "reason": str(verdict.redo), "prompt": new_prompt})
			res.ok = true
			res.msg = "从复审里撤回并重画（第 %d 轮）：%s" % [int(a.round) + 1, str(verdict.redo)]
			return res
		if verdict.has("note") and str(verdict.note) != "":
			a["claude_note"] = str(verdict.note)
			if new_prompt != "":
				a["prompt"] = new_prompt
			_log(a, now, {"event": "claude_note", "note": str(verdict.note)})
			res.ok = true
			res.msg = "已更新给用户看的说明"
			return res
	if has_pick or has_redo:
		if st != "candidates":
			res.msg = "这项现在不在初审阶段（状态：%s）" % (st if st != "" else "未生成")
			return res
		if candidates.is_empty():
			res.msg = "候选/ 里找不到这项的图"
			return res
	if has_pick:
		var pick := _resolve_candidate(verdict.pick, candidates)
		if pick == "":
			res.msg = "pick 指定的图不在候选里：%s（可用：%s）" % [str(verdict.pick), ", ".join(PackedStringArray(candidates))]
			return res
		var alt := ""
		if verdict.has("alt") and str(verdict.alt) != "":
			alt = _resolve_candidate(verdict.alt, candidates)
			if alt == "" or alt == pick:
				res.msg = "alt 指定的图不在候选里，或者和 pick 是同一张：%s" % str(verdict.alt)
				return res
		a["status"] = "user_review"
		a["pick"] = pick
		a["alt"] = alt
		a["claude_note"] = str(verdict.get("note", ""))
		res.to_review = [pick] if alt == "" else [pick, alt]
		for c: String in candidates:
			if c != pick and c != alt:
				res.to_reject.append(c)
		_log(a, now, {"event": "claude_pick", "pick": pick, "alt": alt, "note": a.claude_note})
		if new_prompt != "":
			a["prompt"] = new_prompt
		res.ok = true
		res.msg = "交给用户复审：%s%s" % [pick, ("（备选 %s）" % alt) if alt != "" else ""]
		return res
	if has_redo:
		if int(a.get("round", 0)) >= max_rounds:
			res.msg = "已经生成 %d 轮（上限 %d）：不再自动重画。请用 pick 挑最好的一张交给用户，在 note 里写清问题" % [int(a.round), max_rounds]
			return res
		a["status"] = "claude_redo"
		a["claude_note"] = str(verdict.redo)
		if new_prompt != "":
			a["prompt"] = new_prompt
		res.to_reject = candidates.duplicate()
		_log(a, now, {"event": "claude_redo", "reason": str(verdict.redo), "prompt": new_prompt})
		res.ok = true
		res.msg = "重画（第 %d 轮）：%s" % [int(a.round) + 1, str(verdict.redo)]
		return res
	if new_prompt != "":
		a["prompt"] = new_prompt
		a["prompt_after_reject"] = st == "user_rejected"
		_log(a, now, {"event": "prompt", "prompt": new_prompt})
		res.ok = true
		res.msg = "提示词已更新"
		return res
	res.msg = "没写 pick / redo / prompt"
	return res


## Accepts "part_sac__r1_2.png", "候选/part_sac__r1_2.png", 2 or "2" (1-based position).
static func _resolve_candidate(v: Variant, candidates: Array) -> String:
	var s := str(v).strip_edges().replace("\\", "/").get_file()
	if s.is_valid_int():
		var i := int(s) - 1
		return str(candidates[i]) if i >= 0 and i < candidates.size() else ""
	if s.ends_with(".0") and s.trim_suffix(".0").is_valid_int():  # JSON numbers arrive as floats
		var j := int(s.trim_suffix(".0")) - 1
		return str(candidates[j]) if j >= 0 and j < candidates.size() else ""
	for c: String in candidates:
		if c == s:
			return c
	return ""


## The user's decision on one asset (an entry of 复审结果.json "items").
## available: file names currently in 待复审/. same_batch: the result file belongs to the current page
## (only needed for old results whose items carry no "pick").
## Nothing changes unless the decision was made on the image that is pending NOW and the file exists.
## Returns {"ok", "msg", "approve": name or "", "reject": [names]} (names inside 待复审/).
static func apply_user(state: Dictionary, id: String, item: Dictionary, now: String, available: Array = [],
		same_batch: bool = true) -> Dictionary:
	var a := asset(state, id)
	var res := {"ok": false, "msg": "", "approve": "", "reject": []}
	if str(a.status) != "user_review":
		res.msg = "这项不在等你复审（状态：%s），已忽略" % str(a.status)
		return res
	var decision := str(item.get("decision", ""))
	var comment := str(item.get("comment", "")).strip_edges()
	var pick: String = str(a.get("pick", ""))
	var alt: String = str(a.get("alt", ""))
	var seen := str(item.get("pick", "")).replace("\\", "/").get_file()
	if seen != "" and seen != pick:
		res.msg = "你复审的是另一张图（%s），现在待复审的是 %s：已忽略，请在新的审核页面上再看一次" % [seen, pick]
		return res
	if seen == "" and not same_batch:
		res.msg = "这份复审结果属于旧的审核页面，已忽略"
		return res
	if decision == "approve":
		var chosen := alt if str(item.get("choice", "pick")) == "alt" and alt != "" else pick
		if not available.is_empty() and not available.has(chosen):
			res.msg = "找不到 待复审/%s（被挪走或删掉了？）：这项保持待复审，请重新生成或把文件放回去" % chosen
			return res
		res.approve = chosen
		for f: String in [pick, alt]:
			if f != "" and f != chosen:
				res.reject.append(f)
		a["status"] = "approved"
		a["approved_file"] = chosen
		a["user_comment"] = comment
		_log(a, now, {"event": "user_approve", "file": chosen, "comment": comment})
		res.ok = true
		res.msg = "通过"
	elif decision == "reject":
		for f: String in [pick, alt]:
			if f != "":
				res.reject.append(f)
		a["status"] = "user_rejected"
		a["user_comment"] = comment
		a["prompt_after_reject"] = false
		a["pick"] = ""
		a["alt"] = ""
		_log(a, now, {"event": "user_reject", "comment": comment})
		res.ok = true
		res.msg = "不要：" + (comment if comment != "" else "（没写原因）")
	else:
		res.msg = "decision 只能是 approve 或 reject"
	return res


static func counts(state: Dictionary) -> Dictionary:
	var c := {"candidates": 0, "user_review": 0, "approved": 0, "claude_redo": 0, "user_rejected": 0, "failed": 0}
	var assets: Dictionary = state.get("assets", {})
	for id: String in assets:
		var st: String = str((assets[id] as Dictionary).get("status", ""))
		if c.has(st):
			c[st] += 1
	return c


# ------------------------------------------------------------------ review page

## Data embedded in 审核页面.html (schema: references/art-studio.md §6).
## processed: {id: relative path}, screens: {name: relative path}; all paths relative to 美术资产/.
static func page_data(entries: Array, state: Dictionary, present: Dictionary, processed: Dictionary,
		screens: Dictionary, model: String, now: String) -> Dictionary:
	var items: Array = []
	var approved := 0
	var p1_total := 0
	var p1_ok := 0
	var assets: Dictionary = state.get("assets", {})
	for e: Dictionary in entries:
		var a: Dictionary = assets.get(e.id, {})
		var ok := str(a.get("status", "")) == "approved" or present.has(e.id)
		if ok:
			approved += 1
		if int(e.priority) == 1:
			p1_total += 1
			if ok:
				p1_ok += 1
		if str(a.get("status", "")) != "user_review":
			continue
		var cat: String = str(e.category)
		var last_prompt := str(a.get("prompt", ""))
		for ev: Dictionary in a.get("history", []):
			if str(ev.get("event", "")) == "gen":
				last_prompt = str(ev.get("prompt", last_prompt))
		items.append({
			"id": e.id, "cn": e.cn, "category": cat, "category_cn": CATEGORY_CN.get(cat, cat),
			"priority": int(e.priority), "mode": e.mode, "mode_cn": ArtManifest.MODE_CN.get(e.mode, e.mode),
			"used_by": e.get("used_by", []),
			"pick": "待复审/" + str(a.get("pick", "")),
			"alt": ("待复审/" + str(a.alt)) if str(a.get("alt", "")) != "" else "",
			"processed": processed.get(e.id, ""),
			"screen": screen_of(e) if screens.has(screen_of(e)) else "",
			"note": str(a.get("claude_note", "")), "round": int(a.get("round", 1)), "prompt": last_prompt,
		})
	return {"batch": int(state.get("batch", 0)), "token": str(state.get("workspace_id", "")), "generated": now, "spent_usd": snappedf(float(state.get("spent_usd", 0.0)), 0.01),
		"model": model, "screens": screens, "items": items,
		"progress": {"approved": approved, "total": entries.size(), "p1_approved": p1_ok, "p1_total": p1_total}}


## Identity of the review set; the page's batch number only changes when this changes, so the
## user's half-finished decisions (kept in the browser per batch) survive a page rebuild.
static func review_signature(state: Dictionary) -> String:
	var rows: Array = []
	var assets: Dictionary = state.get("assets", {})
	for id: String in assets:
		var a: Dictionary = assets[id]
		if str(a.get("status", "")) == "user_review":
			rows.append("%s|%s|%s" % [id, str(a.get("pick", "")), str(a.get("alt", ""))])
	rows.sort()
	return ",".join(PackedStringArray(rows)).md5_text()


## Which QA screenshot shows this asset in the game (review page thumbnail).
static func screen_of(entry: Dictionary) -> String:
	if bool(entry.get("enemy", false)):
		return "art_enemies"
	return str(SCREEN_OF.get(str(entry.get("category", "")), "art_gallery"))


# ------------------------------------------------------------------ files

## <id>__r<generation>_<k>.<ext>; the generation counter never resets, so names never collide.
static func candidate_name(id: String, gen: int, k: int, ext: String) -> String:
	return "%s__r%d_%d.%s" % [id, gen, k, ext]


static func id_of_candidate(file: String) -> String:
	return file.get_file().get_slice("__", 0)


## Real image type from magic bytes: "png" | "jpg" | "webp" | "" (unknown).
static func image_ext(bytes: PackedByteArray) -> String:
	if bytes.size() >= 8 and bytes[0] == 0x89 and bytes[1] == 0x50 and bytes[2] == 0x4E and bytes[3] == 0x47:
		return "png"
	if bytes.size() >= 3 and bytes[0] == 0xFF and bytes[1] == 0xD8 and bytes[2] == 0xFF:
		return "jpg"
	if bytes.size() >= 12 and bytes.slice(0, 4).get_string_from_ascii() == "RIFF" and bytes.slice(8, 12).get_string_from_ascii() == "WEBP":
		return "webp"
	return ""


# ------------------------------------------------------------------ API errors

## HTTP outcome -> {"msg": Chinese explanation, "fatal": stop the whole run, "retry": safe to try again,
## "maybe_billed": the provider may already have charged for this request (never retried automatically),
## "drop_param": optional parameter the endpoint rejected}. The caller redacts msg (see redact()).
## proxy_on: a proxy is configured; had_success: an earlier request of this run already worked.
static func explain_error(result: int, code: int, body: Dictionary, host: String, model: String,
		proxy_on: bool = false, had_success: bool = false) -> Dictionary:
	var err: Dictionary = body.get("error", {}) if body.get("error", null) is Dictionary else {}
	var message := str(err.get("message", "")).left(300)
	var ecode := str(err.get("code", ""))
	var etype := str(err.get("type", ""))
	if result != HTTPRequest.RESULT_SUCCESS:
		if result == HTTPRequest.RESULT_TIMEOUT:
			return {"msg": "等了太久没有返回（超时）。这张可能已经生成并计费，所以不自动重试；需要的话稍后 gen redo", "fatal": false, "retry": false, "maybe_billed": true}
		if result in [HTTPRequest.RESULT_CONNECTION_ERROR, HTTPRequest.RESULT_NO_RESPONSE,
				HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH, HTTPRequest.RESULT_BODY_DECOMPRESS_FAILED]:
			return {"msg": "连接在请求中途断开（网络或代理不稳定）。这张可能已经计费，所以不自动重试；稍后 gen redo", "fatal": false, "retry": false, "maybe_billed": true}
		if proxy_on:
			return {"msg": "通过代理连不上 %s：检查代理软件是否开着、GPTapi.txt 里 proxy= 的端口是否正确" % host, "fatal": true, "retry": false}
		if had_success:
			return {"msg": "突然连不上 %s 了（网络断开？）：恢复后重跑同一条 gen 会接着做" % host, "fatal": true, "retry": false}
		return {"msg": "连不上 %s。如果你在中国大陆，需要代理或中转：在 GPTapi.txt 加一行 proxy=http://127.0.0.1:端口（代理软件里能看到端口，常见 7890），或者 base_url=中转服务地址" % host,
			"fatal": true, "retry": false}
	if code >= 300 and code < 400:
		return {"msg": "接口地址被重定向（HTTP %d）。为了不把 Key 发到别的网站，已停止：请把 GPTapi.txt 里的 base_url 改成服务商给的最新地址" % code, "fatal": true, "retry": false}
	match code:
		401:
			return {"msg": "Key 无效（401）：检查 GPTapi.txt 是否完整复制、没有多余字符，Key 是否已被删除", "fatal": true, "retry": false}
		403:
			if message.to_lower().contains("verif"):
				return {"msg": "%s 需要先在 OpenAI 后台完成组织验证：platform.openai.com → Settings → Organization → Verify（几分钟到几小时生效）" % model, "fatal": true, "retry": false}
			return {"msg": "没有权限使用 %s（403）：%s" % [model, message], "fatal": true, "retry": false}
		404:
			if ecode == "model_not_found" or message.to_lower().contains("model"):
				return {"msg": "模型 %s 不可用（404）：在 GPTapi.txt 加一行 model=你账户能用的模型名（例如 gpt-image-1-mini）" % model, "fatal": true, "retry": false}
			return {"msg": "接口地址不对（404）：检查 GPTapi.txt 里的 base_url", "fatal": true, "retry": false}
		429:
			if ecode == "insufficient_quota" or etype == "insufficient_quota" or message.to_lower().contains("quota"):
				return {"msg": "账户余额不足或没有绑定付款方式（insufficient_quota）：到 platform.openai.com → Billing 充值后再试", "fatal": true, "retry": false}
			return {"msg": "请求太快被限流（429），稍等后自动重试", "fatal": false, "retry": true}
		400:
			if ecode == "moderation_blocked" or ecode == "content_policy_violation" or message.to_lower().contains("safety"):
				return {"msg": "提示词被安全系统拦截：需要改写提示词（避开 gore、blood、corpse、weapon，以及过于暴露的服装描述）", "fatal": false, "retry": false}
			for p: String in ["moderation", "background", "output_format", "quality"]:
				if message.contains("'" + p + "'") or message.contains("\"" + p + "\"") or message.contains(" " + p + " ") or ecode == "unknown_parameter" and message.contains(p):
					return {"msg": "接口不支持参数 %s，去掉后重试" % p, "fatal": false, "retry": true, "drop_param": p}
			return {"msg": "请求被拒绝（400）：%s" % message, "fatal": false, "retry": false}
		502, 504, 520, 522, 524:  # gateway timeouts: the upstream may have finished (and billed) anyway
			return {"msg": "网关超时（%d）：这张可能已经生成并计费，所以不自动重试；稍后 gen redo" % code, "fatal": false, "retry": false, "maybe_billed": true}
	if code >= 500:
		return {"msg": "OpenAI 服务器出错（%d），稍后自动重试一次" % code, "fatal": false, "retry": true, "server_error": true}
	return {"msg": "意外的返回（HTTP %d）：%s" % [code, message], "fatal": false, "retry": false}
