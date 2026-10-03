extends TestCase


func test_budget_and_stability_respected() -> void:
	var r := rng(21)
	for race: String in db.races:
		for tier in [1, 2, 3]:
			var team := EnemyFactory.generate(db, r, race, tier, false)
			check_eq(team.size(), EnemyFactory.team_size(tier, false), "%s t%d size" % [race, tier])
			var spent := 0.0
			for spec: Dictionary in team:
				check_eq(UnitBuilder.genome_info(spec, db).overload, 0, "%s no overload" % race)
				for g: Dictionary in UnitBuilder.resolve_genes(spec, db):
					spent += GeneMath.gene_power(g)
			check(spent <= EnemyFactory.budget(tier, false) * Defs.ENEMY_POWER_MULT + 0.75 * team.size() + 0.01,
				"%s t%d within budget (%.1f)" % [race, tier, spent])


func test_elite_prefers_synergy() -> void:
	var r := rng(5)
	var hits := 0
	var total := 0
	for i in 40:
		var team := EnemyFactory.generate(db, r, "fungal", 2, true)
		for spec: Dictionary in team:
			for g: Dictionary in UnitBuilder.resolve_genes(spec, db):
				total += 1
				for t: String in ["infect", "death", "spread"]:
					if g.get("tags", []).has(t):
						hits += 1
						break
	check(total > 0 and float(hits) / total > 0.6, "elite genes mostly on-theme (%d/%d)" % [hits, total])


func test_boss_has_core_and_escorts() -> void:
	var team := EnemyFactory.generate_boss(db, rng(1), "rotbrood_matriarch")
	check_eq(team[0].template, "boss_rotbrood", "boss first")
	check(team.size() >= 3, "boss + escorts")
	var sim := CombatSim.new(db, rng(2))
	sim.add_team(team, 1)
	check_eq(sim.living(1).size(), team.size(), "all boss units placed")
