class_name ArtManifest
extends RefCounted
## Expands data/art_manifest.json + the game's content into the full list of art assets.
## The list is DERIVED: add a gene with a new visual part, a biome or a card and the
## audit immediately reports the new missing asset with a ready-to-use prompt.
## entry = {id, category, cn, path, mode, canvas[w,h], fit, ratio, gen_size, bg, priority,
##          prompt, negative, used_by, socket?, anchor?, height?, size?, hollow?}

const CATEGORY_ORDER := ["body", "part", "background", "icon", "ui", "boss", "card_art"]
const GEN_SIZE := {"1:1": "1024×1024", "16:9": "1920×1080", "5:7": "1024×1434", "4:3": "1024×768", "3:1": "1536×512"}


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
			"path": "res://art/parts/%s.png" % kind, "mode": spec.get("mode", "palette"), "canvas": [256, 256], "fit": "fit",
			"ratio": "1:1", "bg": "纯白", "priority": 3 if u.genes.is_empty() else (1 if early.has(race) else 2),
			"prompt": "%s. Subject: %s. Surface materials: %s. %s" % [style.get("part", ""),
				spec.get("subject", kind), race_art.get(race, "creature"), clause],
			"negative": style.get("negative", ""), "used_by": u.genes,
			"socket": spec.get("socket", "core"), "anchor": spec.get("anchor", "center"),
			"height": float(spec.get("height", 20)), "accent": accent, "hollow": bool(spec.get("hollow", false)),
		})

	# --- bodies (palette mode) ----------------------------------------------
	for plan: String in Defs.BODY_PLANS:
		var b: Dictionary = (m.get("bodies", {}) as Dictionary).get(plan, {})
		var race: String = b.get("race", "")
		out.append({
			"id": "body_" + plan, "category": "body", "kind": plan, "cn": b.get("cn", plan),
			"path": "res://art/bodies/%s.png" % plan, "mode": b.get("mode", "palette"), "canvas": [512, 512], "fit": "fit",
			"ratio": "1:1", "bg": "纯白", "priority": 1 if early.has(race) else 2,
			"prompt": "%s. Subject: %s. Surface materials: %s. %s" % [style.get("body", ""), b.get("subject", plan),
				race_art.get(race, ""), style.get("no_accent_clause", "")],
			"negative": style.get("negative_body", style.get("negative", "")), "used_by": [db.races.get(race, {}).get("name", race)],
			"anchor": "bottom_center", "body_fit": b.get("fit", "height"), "size": float(b.get("size", 130)),
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
static func to_text(entries: Array) -> String:
	var lines := PackedStringArray()
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
