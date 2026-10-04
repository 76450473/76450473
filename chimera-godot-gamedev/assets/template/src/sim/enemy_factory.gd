class_name EnemyFactory
extends RefCounted
## Enemies are built from the SAME gene language as the player, so every enemy is a
## readable "build" the player can learn from and later steal (dissect) from.
##   normal : random legal genes under a power budget + stability capacity
##   elite  : picks a synergy template and strongly prefers genes with its tags
##   boss   : fixed core mechanic (boss unit innate) + generated support genes + escorts


static func team_size(tier: int, elite: bool) -> int:
	return clampi(2 + tier + (1 if elite else 0), 2, 6)


static func budget(tier: int, elite: bool) -> float:
	return (4.0 + tier * 3.0) * (1.5 if elite else 1.0)


## power_mult: enemies get Defs.ENEMY_POWER_MULT because the player also has tactic cards.
## Pass 1.0 when using the factory to roll a *player* team (balance sim, quick-start builds).
static func generate(db: GameData, rng: RandomNumberGenerator, race: String, tier: int,
		elite: bool = false, biome: Dictionary = {}, power_mult: float = Defs.ENEMY_POWER_MULT) -> Array:
	var templates := db.recruitable_units(race)
	if templates.is_empty():
		return []
	var synergy := _pick_synergy(db, rng, race) if elite else {}
	var count := team_size(tier, elite)
	var points := budget(tier, elite) * power_mult
	var per_unit := points / count
	var specs: Array = []
	for i in count:
		var tpl: Dictionary = templates[rng.randi_range(0, templates.size() - 1)]
		var spec := {"template": tpl.id, "genes": [], "enemy": true}  # "enemy": villain art (visual only)
		_fill_genes(db, rng, spec, race, per_unit, synergy, biome)
		specs.append(spec)
	_assign_positions(db, specs)
	if elite and not synergy.is_empty():
		for s: Dictionary in specs:
			s["synergy"] = synergy.get("id", "")
	return specs


static func generate_boss(db: GameData, rng: RandomNumberGenerator, boss_id: String) -> Array:
	var boss: Dictionary = db.bosses.get(boss_id, {})
	if boss.is_empty():
		return []
	var core := {"template": boss.unit, "genes": [], "boss": boss_id, "enemy": true}
	var races: Array = boss.get("support_races", [])
	var race: String = races[rng.randi_range(0, races.size() - 1)] if not races.is_empty() else ""
	_fill_genes(db, rng, core, race, float(boss.get("support_budget", 6)), {}, {})
	var specs: Array = [core]
	for escort_id: String in boss.get("escorts", []):
		var e := {"template": escort_id, "genes": [], "enemy": true}
		_fill_genes(db, rng, e, db.get_unit(escort_id).get("race", ""), 2.5, {}, {})
		specs.append(e)
	_assign_positions(db, specs)
	return specs


static func _pick_synergy(db: GameData, rng: RandomNumberGenerator, race: String) -> Dictionary:
	var pool: Array = []
	for s: Dictionary in db.synergies:
		if s.get("race", "") == race:
			pool.append(s)
	return pool[rng.randi_range(0, pool.size() - 1)] if not pool.is_empty() else {}


static func _fill_genes(db: GameData, rng: RandomNumberGenerator, spec: Dictionary, race: String,
		points: float, synergy: Dictionary, biome: Dictionary) -> void:
	var pool: Array = db.genes_of_race(race)
	var biome_races: Array = biome.get("enemy_races", [])
	for r: String in biome_races:
		if r != race:
			pool.append_array(db.genes_of_race(r))
	var spent: float = 0.0
	for attempt in 12:
		var candidates: Array = []
		var weights: Array = []
		for g: Dictionary in pool:
			if not UnitBuilder.can_attach(spec, g, db):
				continue
			var p := GeneMath.gene_power(g)
			if spent + p > points + 0.75:
				continue
			var trial := spec.duplicate(true)
			trial.genes.append(g.id)
			if UnitBuilder.genome_info(trial, db).overload > 0:
				continue
			var w := 1.0 if g.get("race", "") == race else 0.3
			if not synergy.is_empty():
				for t: String in synergy.get("tags", []):
					if g.get("tags", []).has(t):
						w *= 4.0
			candidates.append(g)
			weights.append(w)
		var idx := RngStreams.weighted_index(rng, weights)
		if idx < 0:
			break
		var chosen: Dictionary = candidates[idx]
		spec.genes.append(chosen.id)
		spent += GeneMath.gene_power(chosen)


## Tanky units front, fragile/fast units back. Deterministic for a given spec list.
static func _assign_positions(db: GameData, specs: Array) -> void:
	var order: Array = []
	for i in specs.size():
		var tpl := db.get_unit(specs[i].template)
		order.append([int(tpl.get("hp", 0)) + int(tpl.get("armor", 0)) * 2, i])
	order.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0] or (a[0] == b[0] and a[1] < b[1]))
	var slots := [Vector2i(1, 0), Vector2i(0, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(2, 1)]
	for k in order.size():
		var spec: Dictionary = specs[order[k][1]]
		var slot: Vector2i = slots[mini(k, slots.size() - 1)]
		spec["lane"] = slot.x
		spec["row"] = slot.y
