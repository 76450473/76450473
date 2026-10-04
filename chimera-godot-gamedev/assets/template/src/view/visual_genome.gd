class_name VisualGenome
extends RefCounted
## Gene data -> appearance description. Pure function, unit-testable, no drawing here.
## Rules (see references/visual-system.md):
##   * skeleton (body_plan) comes from the template race; it only "leaps" to a foreign
##     plan when foreign weight >= 2x base weight (overload / heavy mutation).
##   * every gene with a visual.part becomes a part in its slot, drawn in the GENE's race
##     shape language; only the top VISUAL_MAX_PROMINENT genes are prominent.
##   * material layers grow gradually with weight (20% chitin = a few plates, 80% = shell).
##   * palette 60/25/15: base race / secondary race / element accent.


static func build(spec: Dictionary, db: GameData) -> Dictionary:
	var tpl := db.get_unit(spec.get("template", ""))
	var base_race: String = tpl.get("race", "human")
	var genes := UnitBuilder.resolve_genes(spec, db)
	var weights := {base_race: Defs.VISUAL_BASE_WEIGHT}
	var total: float = Defs.VISUAL_BASE_WEIGHT
	for g: Dictionary in genes:
		var w: float = float(g.get("stability", 1))
		weights[g.race] = float(weights.get(g.race, 0.0)) + w
		total += w

	var foreign_best := ""
	var foreign_w: float = 0.0
	for r: String in weights:
		if r != base_race and float(weights[r]) > foreign_w:
			foreign_w = weights[r]
			foreign_best = r
	var dominant := base_race
	if foreign_best != "" and foreign_w >= 2.0 * Defs.VISUAL_BASE_WEIGHT:
		dominant = foreign_best
	var secondary := ""
	if foreign_best != "" and foreign_w / total >= 0.2:
		secondary = foreign_best if dominant == base_race else base_race

	# parts, ordered by prominence (stability cost, then slot order for determinism)
	var parts: Array = []
	for g: Dictionary in genes:
		var vis: Dictionary = g.get("visual", {})
		var kind: String = vis.get("part", "none")
		if kind == "none":
			continue
		var art_spec: Dictionary = (db.art.get("parts", {}) as Dictionary).get(kind, {})
		parts.append({"slot": g.get("slot", "core"), "kind": kind, "race": g.race,
			"socket": art_spec.get("socket", "core"),
			"shape": db.races.get(g.race, {}).get("shape", "symmetric"),
			"element": GeneMath.main_element(g), "weight": float(g.get("stability", 1)),
			"gene": g.get("name", "")})
	parts.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.weight > b.weight or (a.weight == b.weight and Defs.SLOTS.find(a.slot) < Defs.SLOTS.find(b.slot)))
	for i in parts.size():
		parts[i]["prominent"] = i < Defs.VISUAL_MAX_PROMINENT

	# material layers: gene layers + inherent layer of each foreign race, scaled by share
	var layers := {}
	for g: Dictionary in genes:
		var layer: String = (g.get("visual", {}) as Dictionary).get("layer", "")
		if layer != "":
			layers[layer] = minf(1.0, float(layers.get(layer, 0.0)) + float(g.get("stability", 1)) / 10.0)
	for r: String in weights:
		if r == base_race:
			continue
		var inherent: String = db.races.get(r, {}).get("layer", "")
		if inherent != "":
			layers[inherent] = minf(1.0, float(layers.get(inherent, 0.0)) + 0.8 * float(weights[r]) / total)
	var top_layers := _top_layers(layers, 2)

	# palette 60 / 25 / 15
	var dom_pal: Dictionary = db.races.get(dominant, {}).get("palette", {})
	var base := Color(dom_pal.get("base", "#cccccc"))
	var dark := Color(dom_pal.get("dark", "#333333"))
	var accent := Color(dom_pal.get("accent", "#ffffff"))
	if secondary != "":
		var sec_pal: Dictionary = db.races.get(secondary, {}).get("palette", {})
		dark = dark.lerp(Color(sec_pal.get("base", "#333333")).darkened(0.35), 0.45)
		base = base.lerp(Color(sec_pal.get("base", "#cccccc")), 0.18)
	var element := _main_element(genes)
	if element != "none" and Defs.ELEMENT_COLOR.has(element):
		accent = Color(Defs.ELEMENT_COLOR[element])

	var hp := int(tpl.get("hp", 10))
	for g: Dictionary in genes:
		hp += int((g.get("stats", {}) as Dictionary).get("hp", 0))
	return {
		"template": tpl.get("id", ""),
		"base_race": base_race,
		"dominant": dominant,
		"secondary": secondary,
		"leaped": dominant != base_race,
		"body_plan": db.races.get(dominant, {}).get("body_plan", "biped"),
		"shape": db.races.get(dominant, {}).get("shape", "symmetric"),
		"weights": weights,
		"parts": parts,
		"layers": top_layers,
		"palette": {"base": base, "dark": dark, "accent": accent},
		"element": element,
		"fx": element if element in ["poison", "infect", "regen", "stun", "vulnerable", "summon"] else "",
		"scale": clampf(0.8 + (hp - 8) / 40.0, 0.75, 1.5),
		"boss": bool(tpl.get("boss", false)),
		"enemy": bool(spec.get("enemy", false)),  # enemies use the villain body art (body_<plan>_enemy) when it exists
		"name": species_name(spec, db, element, parts),
	}


static func species_name(spec: Dictionary, db: GameData, element: String, parts: Array) -> String:
	var tpl := db.get_unit(spec.get("template", ""))
	if spec.has("name"):
		return str(spec.name)
	if tpl.get("boss", false):
		return str(tpl.get("name", "?"))
	var grammar := db.species_names
	var prefix: String = (grammar.get("element_prefix", {}) as Dictionary).get(element, "")
	var part_word := ""
	if not parts.is_empty():
		part_word = (grammar.get("part_word", {}) as Dictionary).get(parts[0].kind, "")
	if prefix == part_word:
		part_word = ""
	var role: String = tpl.get("role", tpl.get("name", ""))
	var full := prefix + part_word + role
	return full if full != role else str(tpl.get("name", role))


static func lineage_label(vg: Dictionary, db: GameData) -> String:
	var base_name: String = db.races.get(vg.base_race, {}).get("name", "?")
	if vg.leaped:
		return "%s→%s跃迁体" % [base_name, db.races.get(vg.dominant, {}).get("adj", "?")]
	if vg.secondary != "":
		return "%s·%s裔" % [base_name, db.races.get(vg.secondary, {}).get("adj", "?")]
	var traces: PackedStringArray = []
	for r: String in vg.weights:
		if r != vg.base_race:
			traces.append(str(db.races.get(r, {}).get("adj", "?")))
	if not traces.is_empty():
		return "%s·微%s" % [base_name, "".join(traces)]
	return "纯血" + base_name


static func _main_element(genes: Array) -> String:
	var score := {}
	for g: Dictionary in genes:
		for eff: Dictionary in g.get("effects", []):
			var el := GeneMath.element_of(eff)
			score[el] = float(score.get(el, 0.0)) + GeneMath.effect_power(eff)
	var best := "none"
	var best_s: float = 1.5  # weak genes do not recolor the creature
	for el: String in score:
		if float(score[el]) > best_s:
			best_s = score[el]
			best = el
	return best


static func _top_layers(layers: Dictionary, n: int) -> Dictionary:
	var keys: Array = layers.keys()
	keys.sort_custom(func(a: String, b: String) -> bool:
		return layers[a] > layers[b] or (layers[a] == layers[b] and a < b))
	var out := {}
	for i in mini(n, keys.size()):
		out[keys[i]] = layers[keys[i]]
	return out
