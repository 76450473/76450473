class_name GeneFusion
extends RefCounted
## Gene fusion = semantic composition, not A+B=C lookup tables.
##
##   form    (形) supplies WHEN + WHERE : trigger + target   (+ name suffix, visual part)
##   essence (质) supplies WHAT         : action + status    (+ name prefix, material layer, race)
##
## Swapping form/essence gives a different gene, so every compatible pair has 2 outcomes.
## Amount is re-solved from a power budget, so any combination is automatically in-band.
## Hidden recipes (data/fusion.json) override the generic rule and are "discovered".
## Biome fusion_mods add a small deterministic twist ("变调").
## Mutation (only when the host unit is overloaded) is the only random part.


static func can_fuse(form: Dictionary, essence: Dictionary) -> bool:
	if form.is_empty() or essence.is_empty() or form.get("id") == essence.get("id"):
		return false
	var a: String = form.get("slot", "")
	var b: String = essence.get("slot", "")
	return a == b or a == "core" or b == "core"


static func result_slot(form: Dictionary, essence: Dictionary) -> String:
	var a: String = form.get("slot", "")
	return a if a != "core" else str(essence.get("slot", "core"))


static func _primary(gene: Dictionary) -> Dictionary:
	var best := {}
	var best_p: float = -1.0
	for eff: Dictionary in gene.get("effects", []):
		var p := GeneMath.effect_power(eff)
		if p > best_p:
			best_p = p
			best = eff
	return best


static func find_recipe(form: Dictionary, essence: Dictionary, db: GameData) -> Dictionary:
	for rx: Dictionary in db.recipes:
		if rx.get("require_cross_race", false) and form.get("race") == essence.get("race"):
			continue
		if _any_tag(form, rx.get("form_tags_any", [])) and _any_tag(essence, rx.get("essence_tags_any", [])):
			return rx
	return {}


static func _any_tag(gene: Dictionary, tags: Array) -> bool:
	for t: String in tags:
		if gene.get("tags", []).has(t):
			return true
	return false


## What the UI shows BEFORE the player commits ("有方向，没答案").
static func predict(form: Dictionary, essence: Dictionary) -> Dictionary:
	var f := _primary(form)
	var e := _primary(essence)
	return {
		"trigger": f.get("trigger", "passive"),
		"target": f.get("target", ""),
		"element": GeneMath.element_of(e) if not e.is_empty() else "stats",
		"slot": result_slot(form, essence),
		"may_be_recipe": true,
	}


static func fuse(form: Dictionary, essence: Dictionary, db: GameData, biome: Dictionary = {}) -> Dictionary:
	assert(can_fuse(form, essence), "incompatible fusion %s + %s" % [form.get("id"), essence.get("id")])
	var r: Dictionary = db.fusion_rules
	var same_race: bool = form.get("race") == essence.get("race")
	var stab_mult: float = float(r.get("same_race_stability", 0.8)) if same_race else float(r.get("cross_race_stability", 1.1))
	var stats := _carry_stats(form, essence, float(r.get("stat_carry", 0.5)))
	var out := {
		"id": "fx_%s__%s" % [form.get("id"), essence.get("id")],
		"race": essence.get("race", form.get("race", "")),
		"slot": result_slot(form, essence),
		"rarity": _rarity_up(form.get("rarity", "common"), essence.get("rarity", "common"), false),
		"stability": maxi(1, int(ceil((int(form.get("stability", 1)) + int(essence.get("stability", 1))) * stab_mult))),
		"name_prefix": essence.get("name_prefix", ""),
		"name_suffix": form.get("name_suffix", ""),
		"tags": _union(form.get("tags", []), essence.get("tags", [])),
		"stats": stats,
		"lineage": [form.get("id"), essence.get("id")],
		"fused": true,
	}
	var rx := find_recipe(form, essence, db)
	if not rx.is_empty():
		out["id"] = "rx_%s__%s" % [form.get("id"), essence.get("id")]
		out["name"] = rx.get("name", "?")
		out["recipe"] = rx.get("id", "")
		out["rarity"] = rx.get("rarity", out.rarity)
		out["effects"] = (rx.get("effects", []) as Array).duplicate(true)
		out["tags"] = _union(out.tags, rx.get("tags", []))
		out["visual"] = (rx.get("visual", {}) as Dictionary).duplicate()
		out["stats"] = {}
		return out

	var f := _primary(form)
	var e := _primary(essence)
	var budget: float = float(r.get("budget_ratio", 0.85)) * (GeneMath.gene_power(form) + GeneMath.gene_power(essence))
	if f.is_empty() or e.is_empty():
		# One side is a pure-stat gene: "reinforcement" — keep the other's behavior, add stats.
		var carrier: Dictionary = essence if f.is_empty() else form
		out["effects"] = (carrier.get("effects", []) as Array).duplicate(true)
		out["stats"] = _sum_stats(carrier.get("stats", {}), (form if carrier == essence else essence).get("stats", {}))
	else:
		var eff := {"trigger": f.get("trigger"), "target": f.get("target"), "action": e.get("action")}
		if e.has("status"):
			eff["status"] = e.status
		if e.has("unit"):
			eff["unit"] = e.unit
		_legalize(eff, essence)
		var unit_p: float = GeneMath.unit_power(eff)
		var remaining: float = budget - GeneMath.stats_power(stats)
		var amount := int(round(remaining / unit_p)) if unit_p > 0.0 else 1
		eff["amount"] = clampi(amount, 1, int(r.get("max_amount", 9)))
		out["effects"] = [eff]
	_apply_biome(out, biome)
	out["name"] = "%s%s" % [out.name_prefix, out.name_suffix]
	out["visual"] = {
		"part": (form.get("visual", {}) as Dictionary).get("part", "none"),
		"layer": (essence.get("visual", {}) as Dictionary).get("layer", ""),
	}
	if out.visual.part == "none":
		out.visual.part = (essence.get("visual", {}) as Dictionary).get("part", "none")
	return out


## Mutation: only rolled when the host unit is over capacity. Sidegrade by default,
## with telegraphed chances of an upgrade (优异突变) or a downgrade (退化).
static func mutate(gene: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var g := gene.duplicate(true)
	var effects: Array = g.get("effects", [])
	if effects.is_empty():
		return g
	var eff: Dictionary = effects[rng.randi_range(0, effects.size() - 1)]
	var before: float = GeneMath.effect_power(eff)
	match rng.randi_range(0, 2):
		0:
			var trig: Array = Defs.TRIGGERS.slice(1)
			eff["trigger"] = trig[rng.randi_range(0, trig.size() - 1)]
		1:
			if eff.get("action") == "apply_status":
				eff["status"] = Defs.STATUSES[rng.randi_range(0, Defs.STATUSES.size() - 1)]
			else:
				eff["action"] = ["damage", "heal", "gain_armor"][rng.randi_range(0, 2)]
		2:
			eff["target"] = Defs.TARGETS[rng.randi_range(0, Defs.TARGETS.size() - 1)]
	_legalize(eff, g)
	var quality := rng.randf()
	var mult := 1.3 if quality < 0.2 else (0.7 if quality > 0.8 else 1.0)
	var unit_p := GeneMath.unit_power(eff)
	eff["amount"] = clampi(int(round(before * mult / unit_p)) if unit_p > 0.0 else 1, 1, 9)
	g["name"] = "畸变·" + str(g.get("name", ""))
	g["mutated"] = "superior" if mult > 1.0 else ("degenerate" if mult < 1.0 else "sidegrade")
	g["id"] = "%s~m%d" % [g.get("id", "gene"), rng.randi() % 10000]
	return g


## Keep the effect sensible: helpful payloads target allies, harmful target enemies
## (unless the essence is explicitly a "sacrifice" gene). Summons always target self.
static func _legalize(eff: Dictionary, essence: Dictionary) -> void:
	if eff.get("action") == "summon":
		eff["target"] = "self"
		return
	var target: String = eff.get("target", "self")
	if eff.get("trigger") == "on_ally_death" and target == "other":
		target = "adjacent_allies"
	var helpful := GeneMath.is_beneficial(eff)
	if helpful and Defs.ENEMY_SIDE_TARGETS.has(target):
		target = Defs.MIRROR_TARGET.get(target, "self")
	elif not helpful and Defs.ALLY_SIDE_TARGETS.has(target) and not essence.get("tags", []).has("sacrifice"):
		target = Defs.MIRROR_TARGET.get(target, "lane_enemy")
	eff["target"] = target


static func _apply_biome(gene: Dictionary, biome: Dictionary) -> void:
	for mod: Dictionary in biome.get("fusion_mods", []):
		for eff: Dictionary in gene.get("effects", []):
			var hit := false
			if mod.has("if_status") and eff.get("status", "") == mod.if_status:
				hit = true
			if mod.has("if_action") and eff.get("action", "") == mod.if_action:
				hit = true
			if hit:
				eff["amount"] = maxi(1, int(eff.get("amount", 1)) + int(mod.get("amount_delta", 0)))
				gene["biome_twist"] = biome.get("id", "")


static func _carry_stats(a: Dictionary, b: Dictionary, ratio: float) -> Dictionary:
	var out := {}
	var summed := _sum_stats(a.get("stats", {}), b.get("stats", {}))
	for k: String in summed:
		var v := int(round(float(summed[k]) * ratio))
		if v != 0:
			out[k] = v
	return out


static func _sum_stats(a: Dictionary, b: Dictionary) -> Dictionary:
	var out := a.duplicate()
	for k: String in b:
		out[k] = int(out.get(k, 0)) + int(b[k])
	return out


static func _union(a: Array, b: Array) -> Array:
	var out := a.duplicate()
	for t: Variant in b:
		if not out.has(t):
			out.append(t)
	return out


static func _rarity_up(a: String, b: String, bump: bool) -> String:
	var i := maxi(Defs.RARITIES.find(a), Defs.RARITIES.find(b))
	if bump:
		i += 1
	return Defs.RARITIES[clampi(i, 0, Defs.RARITIES.size() - 1)]
