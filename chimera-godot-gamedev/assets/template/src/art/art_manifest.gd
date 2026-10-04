class_name ArtManifest
extends RefCounted
## Expands data/art_manifest.json + the game's content into the full list of art assets.
## The list is DERIVED: add a gene with a new visual part, a biome or a card and the
## audit immediately reports the new missing asset with a ready-to-use prompt.
## entry = {id, category, cn, path, mode, canvas[w,h], fit, ratio, gen_size, bg, priority,
##          prompt, negative, used_by, socket?, anchor?, height?, size?, hollow?}

const CATEGORY_ORDER := ["body", "part", "background", "icon", "ui", "boss", "card_art"]
const GEN_SIZE := {"1:1": "1024×1024", "16:9": "1920×1080", "5:7": "1024×1434", "4:3": "1024×768", "3:1": "1536×512",
	"2:3": "1024×1536"}


static func build(db: GameData) -> Array:
	var m: Dictionary = db.art
	var style: Dictionary = m.get("style", {})
	var race_art: Dictionary = m.get("race_art", {})
	var early := _early_races(db)
	var prefer := {}  # tie-break for shared parts: playable races first, then early enemies
	for r: String in early:
		prefer[r] = 0.5 if db.races[r].get("playable", false) else 0.25
	var out: Array = []

	# --- creature parts (palette mode) -------------------------------------
	var users := {}  # kind -> {"genes": [names], "races": {race: n}}
	var gene_ids: Array = db.genes.keys()
	gene_ids.sort()
	for gid: String in gene_ids:
		var g: Dictionary = db.genes[gid]
		var kind: String = (g.get("visual", {}) as Dictionary).get("part", "none")
		if kind == "none":
			continue
		if not users.has(kind):
			users[kind] = {"genes": [], "races": {}}
		users[kind].genes.append(g.get("name", gid))
		users[kind].races[g.race] = int(users[kind].races.get(g.race, 0)) + 1
	for kind: String in Defs.PART_KINDS:
		if kind == "none":
			continue
		var spec: Dictionary = (m.get("parts", {}) as Dictionary).get(kind, {})
		var u: Dictionary = users.get(kind, {"genes": [], "races": {}})
		var race := _top_key(u.races, prefer)
		var accent: String = spec.get("accent", "")
		var clause: String = (str(style.get("accent_clause", "")).replace("{accent}", accent)) if accent != "" \
			else str(style.get("no_accent_clause", ""))
		out.append({
			"id": "part_" + kind, "category": "part", "kind": kind,
			"cn": "%s（%s部件）" % [spec.get("cn", kind), db.races.get(race, {}).get("name", "通用")],
			"path": "res://art/parts/%s.png" % kind, "mode": spec.get("mode", m.get("part_mode", "palette")), "canvas": [256, 256], "fit": "fit",
			"ratio": "1:1", "bg": "纯白", "priority": 3 if u.genes.is_empty() else (1 if early.has(race) else 2),
			"prompt": ("%s. Subject: %s. %s. %s" % [style.get("part", ""),
				spec.get("subject", kind), race_art.get(race, "creature"), clause]).strip_edges(),
			"negative": style.get("negative", ""), "used_by": u.genes,
			"socket": spec.get("socket", "core"), "anchor": spec.get("anchor", "center"),
			"height": float(spec.get("height", 20)), "accent": accent, "hollow": bool(spec.get("hollow", false)),
		})

	# --- bodies: one hero standee per body plan + a villain version for enemies ----
	var first_enemies: Array = [] if db.biomes.is_empty() else (db.biomes.values()[0] as Dictionary).get("enemy_races", [])
	for plan: String in Defs.BODY_PLANS:
		var b: Dictionary = (m.get("bodies", {}) as Dictionary).get(plan, {})
		var race: String = b.get("race", "")
		var ratio: String = b.get("ratio", m.get("body_ratio", "1:1"))
		out.append({
			"id": "body_" + plan, "category": "body", "kind": plan, "cn": b.get("cn", plan),
			"path": "res://art/bodies/%s.png" % plan, "mode": b.get("mode", m.get("body_mode", "palette")),
			"canvas": b.get("canvas", m.get("body_canvas", [512, 512])), "fit": "fit",
			"ratio": ratio, "bg": "纯白", "priority": 1 if early.has(race) else 2,
			"prompt": ("%s. Character: %s. %s. %s" % [style.get("body", ""), b.get("subject", plan),
				race_art.get(race, ""), style.get("no_accent_clause", "")]).strip_edges(),
			"negative": style.get("negative_body", style.get("negative", "")), "used_by": [db.races.get(race, {}).get("name", race)],
			"anchor": "bottom_center", "body_fit": b.get("fit", "height"), "size": float(b.get("size", 130)),
			"sockets": b.get("sockets", m.get("default_body_sockets", {})),
		})
		if str(b.get("enemy_subject", "")) == "":
			continue
		out.append({
			"id": "body_%s_enemy" % plan, "category": "body", "kind": plan, "enemy": true,
			"cn": str(b.get("enemy_cn", "%s·敌方反派" % b.get("cn", plan))),
			"path": "res://art/bodies/%s_enemy.png" % plan, "mode": b.get("mode", m.get("body_mode", "palette")),
			"canvas": m.get("enemy_body_canvas", m.get("body_canvas", [512, 512])), "fit": "fit",
			"ratio": ratio, "bg": "纯白", "priority": 1 if first_enemies.has(race) else 2,
			"prompt": ("%s. Character: %s. %s." % [style.get("enemy_body", style.get("body", "")),
				b.get("enemy_subject", ""), race_art.get(race, "")]).strip_edges(),
			"negative": style.get("negative_enemy", style.get("negative_body", "")),
			"used_by": ["敌方%s" % db.races.get(race, {}).get("name", race)],
			"anchor": "bottom_center", "body_fit": "height", "size": float(b.get("enemy_size", m.get("enemy_body_size", 170))),
			"sockets": b.get("enemy_sockets", m.get("enemy_body_sockets", {})),
		})

	# --- biome backgrounds (color) -------------------------------------------
	var first_biome := true
	for bid: String in db.biomes:
		var ba: Dictionary = (m.get("biome_art", {}) as Dictionary).get(bid, {})
		out.append({
			"id": "bg_" + bid, "category": "background", "cn": "战斗背景·%s" % ba.get("cn", bid),
			"path": "res://art/bg/%s.png" % bid, "mode": "color", "canvas": [1600, 900], "fit": "cover",
			"ratio": "16:9", "bg": "画面本身", "priority": 1 if first_biome else 2,
			"prompt": "%s. Scene: %s." % [style.get("background", ""), ba.get("subject", bid)],
			"negative": style.get("negative_background", style.get("negative_color_ok", "")), "used_by": [db.biomes[bid].get("name", bid)],
		})
		first_biome = false

	# --- icons (mono) ----------------------------------------------------------
	var icons: Dictionary = m.get("icons", {})
	for iid: String in icons:
		var ic: Dictionary = icons[iid]
		out.append({
			"id": "icon_" + iid, "category": "icon", "cn": ic.get("cn", iid),
			"path": "res://art/icons/%s.png" % iid, "mode": "mono", "canvas": [128, 128], "fit": "fit",
			"ratio": "1:1", "bg": "纯黑", "priority": int(ic.get("priority", 2)),
			"prompt": "%s. Symbol: %s." % [style.get("icon", ""), ic.get("subject", iid)],
			"negative": style.get("negative_icon", style.get("negative", "")), "used_by": [], "anchor": "center",
		})

	# --- boss illustrations (cutout) -------------------------------------------
	for boss_id: String in db.bosses:
		var ba2: Dictionary = (m.get("boss_art", {}) as Dictionary).get(boss_id, {})
		out.append({
			"id": "boss_" + boss_id, "category": "boss", "cn": ba2.get("cn", boss_id),
			"path": "res://art/boss/%s.png" % boss_id, "mode": "cutout", "canvas": [768, 768], "fit": "fit",
			"ratio": "1:1", "bg": "纯白", "priority": 2,
			"prompt": "%s. Full body side view facing left, isolated, thick closed dark outline around the whole silhouette, plain flat pure white background, no ground, no cast shadow. Subject: %s." % [
				style.get("illustration", ""), ba2.get("subject", boss_id)],
			"negative": style.get("negative_boss", style.get("negative_color_ok", "")), "used_by": [db.bosses[boss_id].get("name", boss_id)],
			"anchor": "bottom_center",
		})

	# --- tactic card illustrations (color) --------------------------------------
	for cid: String in db.cards:
		var ca: Dictionary = (m.get("card_art", {}) as Dictionary).get(cid, {})
		out.append({
			"id": "cardart_" + cid, "category": "card_art", "cn": "卡图·%s" % ca.get("cn", cid),
			"path": "res://art/cards/%s.png" % cid, "mode": "color", "canvas": [512, 384], "fit": "cover",
			"ratio": "4:3", "bg": "画面本身", "priority": 2,
			"prompt": "%s. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: %s." % [style.get("illustration", ""), ca.get("subject", cid)],
			"negative": style.get("negative_color_ok", ""), "used_by": [db.cards[cid].get("name", cid)],
		})

	# --- extras (UI, title) -------------------------------------------------------
	for ex: Dictionary in m.get("extras", []):
		var e := ex.duplicate(true)
		e["category"] = "ui"
		e["bg"] = "纯白" if e.get("mode", "") == "cutout" else "画面本身"
		e["prompt"] = "%s. %s." % [style.get(e.get("style", "ui"), ""), e.get("subject", "")]
		e["negative"] = e.get("negative", style.get("negative_ui" if str(e.get("style", "ui")) == "ui" else "negative_color_ok", ""))
		e["used_by"] = []
		out.append(e)

	for e: Dictionary in out:
		e["gen_size"] = GEN_SIZE.get(e.ratio, "1024×1024")
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.priority != b.priority:
			return a.priority < b.priority
		var ca := CATEGORY_ORDER.find(a.category)
		var cb := CATEGORY_ORDER.find(b.category)
		return ca < cb or (ca == cb and str(a.id) < str(b.id)))
	return out


## Markdown prompt book. Used for docs/ART_TODO.md (missing only) and docs/ART_PROMPTS.md (all).
static func to_markdown(entries: Array, title: String, intro: String) -> String:
	var lines := PackedStringArray(["# " + title, "", intro, ""])
	var names := {1: "P1 · 先做（M1–M2 需要）", 2: "P2 · 其次（M3–M5）", 3: "P3 · 锦上添花"}
	var current := -1
	var n := 0
	for e: Dictionary in entries:
		if int(e.priority) != current:
			current = int(e.priority)
			lines.append("## " + str(names.get(current, "P%d" % current)))
			lines.append("")
		n += 1
		var present := " ✅ 已导入" if is_present(e) else ""
		lines.append("### %d. `%s` — %s%s" % [n, e.id, e.cn, present])
		lines.append("- 保存为：`art_inbox/%s.png`　｜　比例 %s（建议 %s）　｜　背景：%s　｜　模式：%s" % [
			e.id, e.ratio, e.gen_size, e.bg, MODE_CN.get(e.mode, e.mode)])
		if not (e.get("used_by", []) as Array).is_empty():
			lines.append("- 用在：" + "、".join(PackedStringArray(e.used_by)))
		lines.append("- 提示词：")
		lines.append("")
		lines.append("```text")
		lines.append(str(e.prompt))
		lines.append("```")
		lines.append("")
		lines.append("- 反向提示词：`%s`" % e.negative)
		lines.append("")
	return "\n".join(lines)


## Plain-text prompt list (Notepad friendly) for the user's asset production run.
## Plain-text list = section 七 of 《美术资产清单与提示词.txt》. With `art` (the manifest dict) it
## starts with a header (total, 定调批, style-reference prompt) so that the file alone can replace
## the user's list in their ChatGPT project after a manifest change.
static func to_text(entries: Array, art: Dictionary = {}) -> String:
	var lines := PackedStringArray()
	if not art.is_empty():
		var ids := {}
		for e: Dictionary in entries:
			ids[e.id] = true
		var anchors := PackedStringArray()
		for raw: String in art.get("anchor_batch", []):
			if ids.has(raw):
				anchors.append(raw + ".png")
		lines.append("《奇美拉纪元》逐项提示词（共 %d 项）—— docs/ART_PROMPTS.txt，Claude 根据游戏数据生成" % entries.size())
		lines.append("给 ChatGPT 项目用（Codex 用 ART_ASSETS.json）：上传后逐项内容、编号和总数以这份为准（和《美术资产清单与提示词.txt》第七节格式相同）。")
		lines.append("")
		lines.append("定调批（第一次生产或换了风格时先做这几项，确认风格）：" + "、".join(anchors))
		var sheet := str((art.get("style", {}) as Dictionary).get("reference_sheet", ""))
		if sheet != "":
			lines.append("风格参考图提示词（可选，不计入总数，不放进资产包；只给本体角色 body_ 和部件 part_ 参照）：")
			lines.append(sheet)
	var names := {1: "P1 · 必做（游戏前期就会用到，至少先做完这一批）", 2: "P2 · 推荐（中后期内容）", 3: "P3 · 可选（锦上添花）"}
	var current := -1
	var n := 0
	var bar := "────────────────────────────────────────────────────────"
	for e: Dictionary in entries:
		if int(e.priority) != current:
			current = int(e.priority)
			lines.append("")
			lines.append("════════════════════════════════════════════════════════")
			lines.append("  " + str(names.get(current, "P%d" % current)))
			lines.append("════════════════════════════════════════════════════════")
		n += 1
		lines.append("")
		lines.append(bar)
		lines.append("【%d】%s.png　　%s" % [n, e.id, e.cn])
		lines.append("比例 %s（建议 %s）｜背景：%s｜%s" % [e.ratio, e.gen_size, e.bg, MODE_CN.get(e.mode, e.mode)])
		if not (e.get("used_by", []) as Array).is_empty():
			lines.append("用在：" + "、".join(PackedStringArray(e.used_by)))
		lines.append("提示词：")
		lines.append(str(e.prompt))
		lines.append("反向提示词：")
		lines.append(str(e.negative))
	return "\n".join(lines)


## Machine-readable list for the Codex art skill (docs/ART_ASSETS.json). Same numbering as to_text.
static func to_json(entries: Array, art: Dictionary) -> String:
	var items: Array = []
	var ids := {}
	var n := 0
	for e: Dictionary in entries:
		n += 1
		ids[e.id] = true
		items.append({
			"n": n, "id": str(e.id), "file": str(e.id) + ".png", "cn": str(e.cn), "priority": int(e.priority),
			"category": str(e.get("category", "")), "villain": bool(e.get("enemy", false)),
			"ratio": str(e.ratio), "gen_size": str(e.gen_size), "bg": str(e.bg), "mode": str(e.mode),
			"prompt": str(e.prompt), "negative": str(e.negative), "used_by": e.get("used_by", []),
		})
	var anchors: Array = []
	for raw: String in art.get("anchor_batch", []):
		if ids.has(raw):
			anchors.append(raw)
	return JSON.stringify({
		"game": "奇美拉纪元 Chimera Epoch", "total": n, "anchor_batch": anchors,
		"reference_sheet": str((art.get("style", {}) as Dictionary).get("reference_sheet", "")),
		"items": items}, "  ", false)


## The 补图请求 the user pastes into Codex (skill chimera-art; the first line invokes it) or into the
## fallback ChatGPT project: file name + list number 【n】 + name + why (missing / redo reason).
## all_entries: the full ordered list (numbering = to_text order); wanted: entries to request;
## reasons: {asset_id: "重做原因"} (absent = 缺失). note: an extra line under the header (e.g. RESTYLE_NOTE).
static func to_request(all_entries: Array, wanted: Array, reasons: Dictionary, note: String = "") -> String:
	var number := {}
	for i in all_entries.size():
		number[(all_entries[i] as Dictionary).id] = i + 1
	var lines := PackedStringArray([
		"$chimera-art 【补图请求】来自 Claude（《奇美拉纪元》）",
		"请按美术技能（或 ChatGPT 项目指令）和清单生产下面这些资产，按文件名找对应的项：每项照常自检，再请我审核。文件名必须和下面完全一致。"])
	if note != "":
		lines.append(note)
	lines.append("")
	var n := 0
	for e: Dictionary in wanted:
		n += 1
		var why := str(reasons.get(e.id, ""))
		lines.append("%d. 【%d】%s.png　%s　—— %s" % [n, int(number.get(e.id, 0)), e.id, e.cn,
			("重做：" + why) if why != "" else "缺失"])
	lines.append("")
	lines.append("（共 %d 项。全部确认后，把图片按上面的文件名保存，打包成 zip 发给 Claude。）" % n)
	return "\n".join(lines)


## Line GPT项目指令 §九 reacts to: redo the style reference + 定调批 once, then the listed items.
const RESTYLE_NOTE := "风格已更换：旧的风格参考图和已通过的旧图都不要再参照，先用新清单（ART_ASSETS.json / ART_PROMPTS.txt）重新选画风、做定调批，请我确认后再做下面的项。"


const MODE_CN := {"palette": "灰度（游戏内自动上色，只有发光处用鲜绿）", "mono": "白色剪影图标",
	"color": "彩色原样", "cutout": "彩色，去背景"}


static func by_id(entries: Array) -> Dictionary:
	var out := {}
	for e: Dictionary in entries:
		out[e.id] = e
	return out


static func is_present(entry: Dictionary) -> bool:
	return FileAccess.file_exists(entry.path)


## Races whose art is needed first: playable races + enemies of the first biome.
static func _early_races(db: GameData) -> Dictionary:
	var out := {}
	for r: String in db.races:
		if db.races[r].get("playable", false):
			out[r] = true
	if not db.biomes.is_empty():
		for r: String in (db.biomes.values()[0] as Dictionary).get("enemy_races", []):
			out[r] = true
	return out


static func _top_key(counts: Dictionary, prefer: Dictionary) -> String:
	var best := ""
	var best_n := -1.0
	for k: String in counts:
		var n := float(counts[k]) + float(prefer.get(k, 0.0))
		if n > best_n:
			best_n = n
			best = k
	return best
