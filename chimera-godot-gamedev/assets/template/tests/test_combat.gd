extends TestCase


func _spec(template: String, genes: Array, lane: int, row: int = 0) -> Dictionary:
	return {"template": template, "genes": genes, "lane": lane, "row": row}


func _sim(p: Array, e: Array, seed_value: int = 1, rules: Dictionary = {}) -> CombatSim:
	var sim := CombatSim.new(db, rng(seed_value), rules)
	sim.add_team(p, 0)
	sim.add_team(e, 1)
	return sim


func test_deterministic() -> void:
	var p := [_spec("human_militia", ["human_spear"], 0), _spec("human_scout", ["insect_venom_gland"], 1)]
	var e := [_spec("fungal_sporeling", ["fungal_spore_sac"], 0), _spec("beast_hunter", ["beast_fangs"], 1)]
	var a := _sim(p, e, 5)
	var b := _sim(p, e, 5)
	a.run_auto()
	b.run_auto()
	check_eq(a.winner, b.winner, "winner")
	check_eq(a.events.size(), b.events.size(), "event count")
	check_eq(JSON.stringify(a.events), JSON.stringify(b.events), "identical event log")


func test_poison_ticks_and_ignores_armor() -> void:
	var sim := _sim([_spec("human_militia", [], 0)], [_spec("crystal_shard", [], 0)])
	var target := sim.living(1)[0]
	target.add_status("poison", 3)
	var armor_before := target.armor
	var hp_before := target.hp
	sim._round_end()
	check_eq(target.hp, hp_before - 3, "poison deals stacks")
	check_eq(target.armor, armor_before, "poison ignores armor")
	check_eq(target.stacks("poison"), 2, "poison decays by 1")


func test_swamp_poison_bonus() -> void:
	var sim := _sim([_spec("human_militia", [], 0)], [_spec("beast_brute", [], 0)], 1, {"poison_tick_bonus": 1})
	var t := sim.living(1)[0]
	t.add_status("poison", 2)
	var hp_before := t.hp
	sim._round_end()
	check_eq(t.hp, hp_before - 3, "biome adds +1 per tick")


func test_armor_absorbs_attack() -> void:
	var sim := _sim([_spec("human_militia", [], 0)], [_spec("crystal_shard", [], 0)])
	var attacker := sim.living(0)[0]
	var target := sim.living(1)[0]
	sim._deal_damage(attacker, target, 5, "attack")
	check_eq(target.armor, 0, "3 armor consumed")
	check_eq(target.hp, target.max_hp - 2, "2 damage through")


func test_death_burst_hits_area() -> void:
	var sim := _sim([_spec("insect_larva", ["insect_death_burst"], 1)],
		[_spec("human_militia", [], 0), _spec("human_militia", [], 1), _spec("human_militia", [], 2)])
	var bomber := sim.living(0)[0]
	sim._lose_hp(bomber, 999, "test")
	var damaged := 0
	for u in sim.living(1):
		if u.hp < u.max_hp or u.armor < 1:
			damaged += 1
	check_eq(damaged, 3, "lane target + both neighbors hit by on_death enemy_area")


func test_infect_spreads_on_death() -> void:
	var sim := _sim([_spec("human_militia", [], 0)],
		[_spec("insect_larva", [], 0), _spec("insect_larva", [], 1), _spec("insect_larva", [], 2)])
	var mid := sim.unit_at(1, 1, 0)
	mid.add_status("infect", 2)
	sim._lose_hp(mid, 999, "test")
	check_eq(sim.unit_at(1, 0, 0).stacks("poison"), 2, "left neighbor poisoned")
	check_eq(sim.unit_at(1, 2, 0).stacks("infect"), 1, "infection spreads decayed")


func test_summon_fills_then_fizzles() -> void:
	var sim := _sim([_spec("insect_drone", [], 0)], [_spec("human_militia", [], 0)])
	sim._summon(0, "insect_broodling", 10, sim.living(0)[0])
	check_eq(sim.living(0).size(), Defs.LANES * Defs.ROWS, "board side full")
	var fails := 0
	for ev in sim.events:
		if ev.type == "summon_fail":
			fails += 1
	check_eq(fails, 1, "extra summons fizzle once and stop")


func test_cards_spend_energy() -> void:
	var sim := _sim([_spec("human_militia", [], 0)], [_spec("beast_brute", [], 0)])
	sim.begin_round()
	var enemy := sim.living(1)[0]
	check(sim.play_card(db.cards.card_strike, 0, enemy.uid), "strike playable")
	check(sim.play_card(db.cards.card_toxin, 0), "toxin playable")
	check(not sim.play_card(db.cards.card_strike, 0, enemy.uid), "out of energy")
	check_eq(enemy.stacks("poison"), 2, "toxin applied")


func test_random_fights_terminate() -> void:
	var r := rng(11)
	var races := ["human", "insect", "fungal", "beast", "crystal", "wraith"]
	for i in 150:
		var a := EnemyFactory.generate(db, r, races[r.randi_range(0, 5)], r.randi_range(1, 3), r.randf() < 0.4)
		var b := EnemyFactory.generate(db, r, races[r.randi_range(0, 5)], r.randi_range(1, 3), r.randf() < 0.4)
		var sim := _sim(a, b, i)
		sim.run_auto()
		check(sim.is_over(), "fight %d ended" % i)
		check(sim.round_num <= Defs.MAX_ROUNDS, "fight %d within max rounds" % i)
