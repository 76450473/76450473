extends TestCase


func test_form_gives_trigger_essence_gives_payload() -> void:
	var g := GeneFusion.fuse(db.get_gene("insect_spray"), db.get_gene("insect_venom_gland"), db)
	var eff: Dictionary = g.effects[0]
	check_eq(eff.trigger, "on_attack", "trigger from form")
	check_eq(eff.target, "enemy_area", "target from form")
	check_eq(eff.action, "apply_status", "action from essence")
	check_eq(eff.status, "poison", "status from essence")
	check_eq(g.name, "毒喷射", "name = essence prefix + form suffix")
	check_eq(g.slot, "limb", "core essence adopts form slot")


func test_order_matters() -> void:
	var a := GeneFusion.fuse(db.get_gene("insect_spray"), db.get_gene("insect_venom_gland"), db)
	var b := GeneFusion.fuse(db.get_gene("insect_venom_gland"), db.get_gene("insect_spray"), db)
	check(a.effects[0].target != b.effects[0].target or a.effects[0].action != b.effects[0].action,
		"swapping form/essence changes the result")


func test_beneficial_payload_mirrors_to_allies() -> void:
	# form = spray (hits enemy area), essence = mycelium regen  -> regen must go to ally area
	var g := GeneFusion.fuse(db.get_gene("insect_spray"), db.get_gene("fungal_rot_touch"), db)
	check_eq(g.effects[0].target, "enemy_area", "harmful stays on enemies")
	var form := db.get_gene("insect_spray").duplicate(true)
	form["slot"] = "skin"
	var h := GeneFusion.fuse(form, db.get_gene("fungal_mycelium_net"), db)
	check_eq(h.effects[0].target, "ally_area", "helpful payload mirrored to allies")


func test_power_budget_in_band() -> void:
	var ids: Array = db.genes.keys()
	var checked := 0
	for a: String in ids:
		for b: String in ids:
			var ga := db.get_gene(a)
			var gb := db.get_gene(b)
			if not GeneFusion.can_fuse(ga, gb):
				continue
			var g := GeneFusion.fuse(ga, gb, db)
			if g.has("recipe"):
				continue
			checked += 1
			var p := GeneMath.gene_power(g)
			var src := GeneMath.gene_power(ga) + GeneMath.gene_power(gb)
			check(p <= src * 1.6 + 1.0, "%s too strong: %.1f from %.1f" % [g.id, p, src])
			check(not GeneMath.describe_gene(g).contains("?"), "%s describable" % g.id)
	check(checked > 50, "enough generic pairs checked (%d)" % checked)


func test_recipe_discovery() -> void:
	var g := GeneFusion.fuse(db.get_gene("insect_death_burst"), db.get_gene("insect_brood"), db)
	check_eq(g.get("recipe", ""), "rx_corpse_brood", "death x breed -> hidden recipe")
	check_eq(g.name, "裂卵尸囊", "recipe name")


func test_biome_twist() -> void:
	var plain := GeneFusion.fuse(db.get_gene("insect_spray"), db.get_gene("insect_venom_gland"), db)
	var swamp := GeneFusion.fuse(db.get_gene("insect_spray"), db.get_gene("insect_venom_gland"), db, db.biomes.swamp)
	check_eq(int(swamp.effects[0].amount), int(plain.effects[0].amount) + 1, "swamp adds +1 poison")
	check_eq(swamp.get("biome_twist", ""), "swamp", "twist recorded")


func test_cross_race_costs_more_stability() -> void:
	var same := GeneFusion.fuse(db.get_gene("insect_spray"), db.get_gene("insect_venom_gland"), db)
	var cross := GeneFusion.fuse(db.get_gene("human_spear"), db.get_gene("insect_venom_gland"), db)
	check(int(cross.stability) > int(same.stability), "cross-race fusion is less stable")


func test_mutation_deterministic() -> void:
	var g := db.get_gene("insect_venom_gland")
	var a := GeneFusion.mutate(g, rng(4))
	var b := GeneFusion.mutate(g, rng(4))
	check_eq(JSON.stringify(a), JSON.stringify(b), "same rng -> same mutation")
	check(str(a.name).begins_with("畸变"), "mutation is labelled")
