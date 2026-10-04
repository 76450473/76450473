class_name GameData
extends RefCounted
## All static game content, loaded from res://data/*.json.
## Pure RefCounted so tests / headless tools can create their own instance
## (the `Data` autoload just wraps one of these as `Data.db`).

const DATA_DIR := "res://data"

var races: Dictionary = {}
var units: Dictionary = {}
var genes: Dictionary = {}
var cards: Dictionary = {}
var biomes: Dictionary = {}
var synergies: Array = []
var bosses: Dictionary = {}
var fusion_rules: Dictionary = {}
var recipes: Array = []
var species_names: Dictionary = {}
var art: Dictionary = {}  # data/art_manifest.json (see ArtManifest)
var load_errors: PackedStringArray = []


static func load_default() -> GameData:
	var db := GameData.new()
	db.load_dir(DATA_DIR)
	return db


func load_dir(dir: String) -> void:
	races = _index(_read(dir + "/races.json").get("races", []))
	units = _index(_read(dir + "/units.json").get("units", []))
	genes = _index(_read(dir + "/genes.json").get("genes", []))
	cards = _index(_read(dir + "/cards.json").get("cards", []))
	biomes = _index(_read(dir + "/biomes.json").get("biomes", []))
	var enemies := _read(dir + "/enemies.json")
	synergies = enemies.get("synergies", [])
	bosses = _index(enemies.get("bosses", []))
	var fusion := _read(dir + "/fusion.json")
	fusion_rules = fusion.get("rules", {})
	recipes = fusion.get("recipes", [])
	species_names = fusion.get("species_names", {})
	art = _read(dir + "/art_manifest.json")


func get_gene(id: String) -> Dictionary:
	return genes.get(id, {})


func get_unit(id: String) -> Dictionary:
	return units.get(id, {})


func genes_of_race(race: String) -> Array:
	var out: Array = []
	for g: Dictionary in genes.values():
		if g.get("race", "") == race:
			out.append(g)
	return out


func unit_names() -> Dictionary:
	var out := {}
	for id: String in units:
		out[id] = units[id].get("name", id)
	return out


func recruitable_units(race: String) -> Array:
	var out: Array = []
	for u: Dictionary in units.values():
		if u.get("race", "") == race and not u.get("summon_only", false) and not u.get("boss", false):
			out.append(u)
	return out


## Returns a list of human-readable problems. Empty list == data is consistent.
func validate() -> PackedStringArray:
	var errs: PackedStringArray = load_errors.duplicate()
	for r: Dictionary in races.values():
		if not Defs.SHAPES.has(r.get("shape", "")):
			errs.append("race %s: unknown shape %s" % [r.id, r.get("shape")])
		if not Defs.BODY_PLANS.has(r.get("body_plan", "")):
			errs.append("race %s: unknown body_plan %s" % [r.id, r.get("body_plan")])
		if not Defs.LAYERS.has(r.get("layer", "")):
			errs.append("race %s: unknown layer %s" % [r.id, r.get("layer")])
	for u: Dictionary in units.values():
		if not races.has(u.get("race", "")):
			errs.append("unit %s: unknown race %s" % [u.id, u.get("race")])
		for s: String in u.get("slots", []):
			if not Defs.SLOTS.has(s):
				errs.append("unit %s: unknown slot %s" % [u.id, s])
		for eff: Dictionary in u.get("innate", []):
			_validate_effect("unit %s innate" % u.id, eff, errs)
	for g: Dictionary in genes.values():
		var where := "gene %s" % g.get("id", "?")
		if not races.has(g.get("race", "")):
			errs.append("%s: unknown race %s" % [where, g.get("race")])
		if not Defs.SLOTS.has(g.get("slot", "")):
			errs.append("%s: unknown slot %s" % [where, g.get("slot")])
		if not Defs.RARITIES.has(g.get("rarity", "")):
			errs.append("%s: unknown rarity %s" % [where, g.get("rarity")])
		for key: String in ["name", "name_prefix", "name_suffix"]:
			if str(g.get(key, "")) == "":
				errs.append("%s: missing %s" % [where, key])
		if int(g.get("stability", 0)) <= 0:
			errs.append("%s: stability must be > 0" % where)
		for k: String in g.get("stats", {}):
			if not Defs.STAT_POWER.has(k):
				errs.append("%s: unknown stat %s" % [where, k])
		for eff: Dictionary in g.get("effects", []):
			_validate_effect(where, eff, errs)
			if eff.get("trigger", "") == "passive":
				errs.append("%s: passive genes use stats, not effects" % where)
		var vis: Dictionary = g.get("visual", {})
		if not Defs.PART_KINDS.has(vis.get("part", "")):
			errs.append("%s: unknown visual part %s" % [where, vis.get("part")])
		if not Defs.LAYERS.has(vis.get("layer", "")):
			errs.append("%s: unknown visual layer %s" % [where, vis.get("layer")])
		var rng_p: Array = Defs.RARITY_POWER.get(g.get("rarity", "common"), [0.0, 99.0])
		var p := GeneMath.gene_power(g)
		if p < float(rng_p[0]) or p > float(rng_p[1]):
			errs.append("%s: power %.2f outside %s range %s" % [where, p, g.get("rarity"), rng_p])
	for c: Dictionary in cards.values():
		if not Defs.CARD_TARGETS.has(c.get("target", "")):
			errs.append("card %s: unknown target %s" % [c.id, c.get("target")])
		for eff: Dictionary in c.get("effects", []):
			var a: String = eff.get("action", "")
			if not (Defs.ACTIONS.has(a) or Defs.CARD_ONLY_ACTIONS.has(a)):
				errs.append("card %s: unknown action %s" % [c.id, a])
			if a == "summon" and not units.has(eff.get("unit", "")):
				errs.append("card %s: unknown summon unit %s" % [c.id, eff.get("unit")])
	for b: Dictionary in biomes.values():
		for r: String in b.get("enemy_races", []):
			if not races.has(r):
				errs.append("biome %s: unknown race %s" % [b.id, r])
	for s: Dictionary in synergies:
		if not races.has(s.get("race", "")):
			errs.append("synergy %s: unknown race" % s.get("id"))
	for b: Dictionary in bosses.values():
		if not units.has(b.get("unit", "")):
			errs.append("boss %s: unknown unit %s" % [b.id, b.get("unit")])
		for gid: String in b.get("dissect", []):
			if not genes.has(gid):
				errs.append("boss %s: unknown dissect gene %s" % [b.id, gid])
		for uid: String in b.get("escorts", []):
			if not units.has(uid):
				errs.append("boss %s: unknown escort %s" % [b.id, uid])
	for rx: Dictionary in recipes:
		for eff: Dictionary in rx.get("effects", []):
			_validate_effect("recipe %s" % rx.get("id"), eff, errs)
	_validate_art(errs)
	return errs


## Every visual/content id must have an art spec, so the audit can always print a prompt.
func _validate_art(errs: PackedStringArray) -> void:
	var parts: Dictionary = art.get("parts", {})
	for kind: String in Defs.PART_KINDS:
		if kind == "none":
			continue
		if not parts.has(kind):
			errs.append("art_manifest: missing parts.%s" % kind)
		else:
			var spec: Dictionary = parts[kind]
			if not Defs.ART_SOCKETS.has(spec.get("socket", "")):
				errs.append("art_manifest: parts.%s unknown socket %s" % [kind, spec.get("socket")])
			if not Defs.ART_ANCHORS.has(spec.get("anchor", "")):
				errs.append("art_manifest: parts.%s unknown anchor %s" % [kind, spec.get("anchor")])
			if str(spec.get("subject", "")) == "":
				errs.append("art_manifest: parts.%s has no subject" % kind)
	var words: Dictionary = species_names.get("part_word", {})
	for kind: String in Defs.PART_KINDS:
		if not words.has(kind):
			errs.append("fusion.json: species_names.part_word missing %s" % kind)
	for plan: String in Defs.BODY_PLANS:
		if not (art.get("bodies", {}) as Dictionary).has(plan):
			errs.append("art_manifest: missing bodies.%s" % plan)
	for r: String in races:
		if not (art.get("race_art", {}) as Dictionary).has(r):
			errs.append("art_manifest: missing race_art.%s" % r)
	for b: String in biomes:
		if not (art.get("biome_art", {}) as Dictionary).has(b):
			errs.append("art_manifest: missing biome_art.%s" % b)
	for st: String in Defs.STATUSES:
		if not (art.get("icons", {}) as Dictionary).has("status_" + st):
			errs.append("art_manifest: missing icons.status_%s" % st)
	for c: String in cards:
		if not (art.get("card_art", {}) as Dictionary).has(c):
			errs.append("art_manifest: missing card_art.%s" % c)
	for b: String in bosses:
		if not (art.get("boss_art", {}) as Dictionary).has(b):
			errs.append("art_manifest: missing boss_art.%s" % b)


func _validate_effect(where: String, eff: Dictionary, errs: PackedStringArray) -> void:
	if not Defs.TRIGGERS.has(eff.get("trigger", "")):
		errs.append("%s: unknown trigger %s" % [where, eff.get("trigger")])
	if not Defs.ACTIONS.has(eff.get("action", "")):
		errs.append("%s: unknown action %s" % [where, eff.get("action")])
	if not Defs.TARGETS.has(eff.get("target", "")):
		errs.append("%s: unknown target %s" % [where, eff.get("target")])
	if eff.get("action", "") == "apply_status" and not Defs.STATUSES.has(eff.get("status", "")):
		errs.append("%s: unknown status %s" % [where, eff.get("status")])
	if eff.get("action", "") == "summon" and not units.has(eff.get("unit", "")):
		errs.append("%s: unknown summon unit %s" % [where, eff.get("unit")])
	if int(eff.get("amount", 0)) <= 0:
		errs.append("%s: amount must be >= 1" % where)


func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		load_errors.append("missing data file " + path)
		return {}
	var json := JSON.new()
	var err := json.parse(FileAccess.get_file_as_string(path))
	if err != OK:
		load_errors.append("%s:%d %s" % [path, json.get_error_line(), json.get_error_message()])
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		load_errors.append("%s: top level must be an object" % path)
		return {}
	return json.data


func _index(rows: Array) -> Dictionary:
	var out := {}
	for row: Dictionary in rows:
		var id := str(row.get("id", ""))
		if id == "":
			load_errors.append("row without id: %s" % row)
		elif out.has(id):
			load_errors.append("duplicate id " + id)
		else:
			out[id] = row
	return out
