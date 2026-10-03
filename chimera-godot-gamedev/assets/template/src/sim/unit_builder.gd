class_name UnitBuilder
extends RefCounted
## Turns a unit *spec* (what a save file / enemy factory stores) into combat stats.
## spec = {"template": "human_militia", "genes": ["insect_venom_gland", {fused gene dict}], "lane": 0, "row": 0}
## Genes may be ids (looked up in GameData) or full dicts (fused / mutated genes live only in the save).


static func resolve_genes(spec: Dictionary, db: GameData) -> Array:
	var out: Array = []
	for g: Variant in spec.get("genes", []):
		if g is Dictionary:
			out.append(g)
		elif db.genes.has(str(g)):
			out.append(db.genes[str(g)])
	return out


## Stability bookkeeping for one unit: load vs capacity, purity.
static func genome_info(spec: Dictionary, db: GameData) -> Dictionary:
	var tpl := db.get_unit(spec.get("template", ""))
	var race: String = tpl.get("race", "")
	var race_def: Dictionary = db.races.get(race, {})
	var traits: Dictionary = race_def.get("traits", {})
	var cross_mult: float = float(traits.get("cross_race_mult", Defs.CROSS_RACE_STABILITY_MULT))
	var capacity: int = int(tpl.get("capacity", 0)) + int(traits.get("capacity_bonus", 0))
	var load_total: float = 0.0
	var pure := true
	var genes := resolve_genes(spec, db)
	for g: Dictionary in genes:
		var cost: float = float(g.get("stability", 1))
		if g.get("race", "") != race:
			cost *= cross_mult
			pure = false
		load_total += cost
	var is_pure := pure and genes.size() >= Defs.PURE_BLOOD_MIN_GENES
	return {"load": int(ceil(load_total)), "capacity": capacity, "pure": is_pure,
		"overload": maxi(0, int(ceil(load_total)) - capacity)}


## Slot rules: gene slot must exist on the template and be free.
static func can_attach(spec: Dictionary, gene: Dictionary, db: GameData) -> bool:
	var tpl := db.get_unit(spec.get("template", ""))
	var slot: String = gene.get("slot", "")
	if not tpl.get("slots", []).has(slot):
		return false
	for g: Dictionary in resolve_genes(spec, db):
		if g.get("slot", "") == slot:
			return false
	return true


static func build(spec: Dictionary, db: GameData, side: int, uid: int) -> UnitState:
	var tpl := db.get_unit(spec.get("template", ""))
	assert(not tpl.is_empty(), "unknown unit template %s" % spec.get("template"))
	var u := UnitState.new()
	u.uid = uid
	u.side = side
	u.lane = int(spec.get("lane", 0))
	u.row = int(spec.get("row", 0))
	u.template_id = tpl.id
	u.race = tpl.get("race", "")
	u.display_name = spec.get("name", tpl.get("name", tpl.id))
	var hp := int(tpl.get("hp", 1))
	u.atk = int(tpl.get("atk", 0))
	u.spd = int(tpl.get("spd", 0))
	u.armor = int(tpl.get("armor", 0))
	for eff: Dictionary in tpl.get("innate", []):
		var e := eff.duplicate()
		e["_gene"] = tpl.get("name", tpl.id)
		u.effects.append(e)
	for g: Dictionary in resolve_genes(spec, db):
		var stats: Dictionary = g.get("stats", {})
		hp += int(stats.get("hp", 0))
		u.atk += int(stats.get("atk", 0))
		u.spd += int(stats.get("spd", 0))
		u.armor += int(stats.get("armor", 0))
		u.gene_ids.append(str(g.get("id", "")))
		for eff: Dictionary in g.get("effects", []):
			var e := eff.duplicate()
			e["_gene"] = g.get("name", g.get("id", "?"))
			u.effects.append(e)
	if genome_info(spec, db).pure:
		hp = int(round(hp * Defs.PURE_BLOOD_HP_MULT))
	u.max_hp = maxi(1, hp)
	u.hp = u.max_hp
	u.atk = maxi(0, u.atk)
	u.spd = maxi(0, u.spd)
	u.armor = maxi(0, u.armor)
	return u
