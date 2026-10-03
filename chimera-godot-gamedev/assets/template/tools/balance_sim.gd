extends SceneTree
## Headless balance report — run after ANY change to data/*.json or Defs numbers.
##   godot --headless --path . --script res://tools/balance_sim.gd -- n=400 seed=1 tier=1 out=reports/balance.csv
## Player: random legal builds of playable races (hybrids allowed) + random card play.
## Enemy : EnemyFactory (25% elites) in a random biome.
## Flags : genes whose presence moves win rate by > 15 points (n >= 20), draw/trigger-cap rates.
## Targets (random-play bot; real players do better): win tier1 65-80%, tier2 55-72%, tier3 45-65%;
## avg rounds 4-9; draws < 3%; trigger caps < 1%; per-enemy-race non-win spread <= 20 points.

var opts := {"n": 400, "seed": 1, "tier": 1, "out": ""}


func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		var kv := a.split("=")
		if kv.size() == 2:
			opts[kv[0]] = kv[1]
	var db := GameData.load_default()
	var errs := db.validate()
	if not errs.is_empty():
		for e in errs:
			printerr("[data] ", e)
		quit(2)
		return
	var streams := RngStreams.new(int(opts.seed))
	var gen := streams.stream("enemy")
	var n := int(opts.n)
	var tier := int(opts.tier)
	var wins := 0
	var draws := 0
	var caps := 0
	var rounds := 0
	var gene_seen := {}
	var gene_won := {}
	var enemy_seen := {}
	var enemy_won := {}
	var race_seen := {}
	var race_lost := {}
	var playable: Array = []
	for r: String in db.races:
		if db.races[r].get("playable", false):
			playable.append(r)
	var hybrid_biome := {"enemy_races": db.races.keys()}
	var biomes: Array = db.biomes.values()
	var deck: Array = db.cards.values()
	for i in n:
		var race: String = playable[gen.randi_range(0, playable.size() - 1)]
		var player := EnemyFactory.generate(db, gen, race, tier, false, hybrid_biome, 1.0)
		var biome: Dictionary = biomes[gen.randi_range(0, biomes.size() - 1)]
		var er: Array = biome.get("enemy_races", [])
		var enemy_race: String = er[gen.randi_range(0, er.size() - 1)]
		var enemy := EnemyFactory.generate(db, gen, enemy_race, tier, gen.randf() < 0.25, biome)
		var sim := CombatSim.new(db, streams.fork("combat"), biome.get("rules", {}))
		sim.add_team(player, 0)
		sim.add_team(enemy, 1)
		var card_rng := streams.fork("reward")
		var w := sim.run_auto(func(s: CombatSim) -> void: _play_random_cards(s, deck, card_rng))
		rounds += sim.round_num
		if w == 0:
			wins += 1
		elif w == -1:
			draws += 1
		if sim.hit_trigger_cap:
			caps += 1
		race_seen[enemy_race] = int(race_seen.get(enemy_race, 0)) + 1
		if w != 0:
			race_lost[enemy_race] = int(race_lost.get(enemy_race, 0)) + 1
		for gid in _gene_ids(player, db):
			gene_seen[gid] = int(gene_seen.get(gid, 0)) + 1
			if w == 0:
				gene_won[gid] = int(gene_won.get(gid, 0)) + 1
		for gid in _gene_ids(enemy, db):
			enemy_seen[gid] = int(enemy_seen.get(gid, 0)) + 1
			if w == 1:
				enemy_won[gid] = int(enemy_won.get(gid, 0)) + 1
	var base := float(wins) / n
	print("=== balance  n=%d tier=%d seed=%s" % [n, tier, opts.seed])
	print("player win %.1f%%  draws %.1f%%  avg rounds %.2f  trigger-cap fights %.1f%%" % [
		base * 100.0, 100.0 * draws / n, float(rounds) / n, 100.0 * caps / n])
	var race_line := PackedStringArray()
	for r: String in race_seen:
		race_line.append("%s %.0f%%" % [r, 100.0 * float(race_lost.get(r, 0)) / int(race_seen[r])])
	print("player non-win rate by enemy race (target spread <= 20 pts): ", ", ".join(race_line))
	var rows: Array = []
	for gid: String in gene_seen:
		var seen := int(gene_seen[gid])
		var wr := float(gene_won.get(gid, 0)) / seen
		rows.append([gid, "player", seen, wr, wr - base])
	var enemy_base := 1.0 - base - float(draws) / n
	for gid: String in enemy_seen:
		var seen := int(enemy_seen[gid])
		var wr := float(enemy_won.get(gid, 0)) / seen
		rows.append([gid, "enemy", seen, wr, wr - enemy_base])
	rows.sort_custom(func(a: Array, b: Array) -> bool: return absf(a[4]) > absf(b[4]))
	print("%-24s %-7s %5s %7s %7s" % ["gene", "side", "n", "win%", "delta"])
	var csv := PackedStringArray(["gene,side,n,win_rate,delta"])
	for r: Array in rows:
		var flag := "  <-- CHECK" if absf(r[4]) > 0.15 and int(r[2]) >= 20 else ""
		print("%-24s %-7s %5d %6.1f%% %+6.1f%s" % [r[0], r[1], r[2], r[3] * 100.0, r[4] * 100.0, flag])
		csv.append("%s,%s,%d,%.4f,%.4f" % r)
	if str(opts.out) != "":
		var path := ProjectSettings.globalize_path("res://" + str(opts.out))
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		var f := FileAccess.open(path, FileAccess.WRITE)
		f.store_string("\n".join(csv))
		print("csv: ", path)
	quit(0)


func _gene_ids(specs: Array, db: GameData) -> PackedStringArray:
	var out: PackedStringArray = []
	for s: Dictionary in specs:
		for g: Dictionary in UnitBuilder.resolve_genes(s, db):
			if not out.has(g.id):
				out.append(g.id)
	return out


func _play_random_cards(sim: CombatSim, deck: Array, r: RandomNumberGenerator) -> void:
	var hand: Array = []
	for i in Defs.HAND_SIZE:
		hand.append(deck[r.randi_range(0, deck.size() - 1)])
	for card: Dictionary in hand:
		if int(card.cost) > sim.energy:
			continue
		var target := -1
		var kind: String = card.target
		if kind == "chosen_enemy" or kind == "chosen_ally":
			var pool := sim.living(1 if kind == "chosen_enemy" else 0)
			if pool.is_empty():
				continue
			target = pool[r.randi_range(0, pool.size() - 1)].uid
		sim.play_card(card, 0, target)
