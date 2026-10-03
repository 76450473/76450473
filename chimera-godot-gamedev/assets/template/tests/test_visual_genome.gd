extends TestCase


func test_pure_human() -> void:
	var vg := VisualGenome.build({"template": "human_militia", "genes": ["human_plating", "human_spear"]}, db)
	check_eq(vg.body_plan, "biped", "human skeleton")
	check_eq(vg.secondary, "", "no secondary race")
	check(not vg.leaped, "no leap")


func test_insect_genes_show_on_human() -> void:
	var vg := VisualGenome.build({"template": "human_militia",
		"genes": ["insect_compound_eye", "insect_carapace", "insect_venom_gland"]}, db)
	check_eq(vg.body_plan, "biped", "skeleton stays human below leap threshold")
	check_eq(vg.secondary, "insect", "insect is the secondary race")
	check(vg.layers.has("chitin"), "chitin layer appears")
	var kinds: Array = []
	for p: Dictionary in vg.parts:
		kinds.append(p.kind)
	check(kinds.has("eye_compound"), "compound eye part present")


func test_gradual_layer() -> void:
	var light := VisualGenome.build({"template": "human_militia", "genes": ["insect_compound_eye"]}, db)
	var heavy := VisualGenome.build({"template": "human_militia",
		"genes": ["insect_compound_eye", "insect_carapace", "insect_spray"]}, db)
	check(float(heavy.layers.get("chitin", 0.0)) > float(light.layers.get("chitin", 0.0)), "more genes -> more chitin")


func test_prominence_cap() -> void:
	var vg := VisualGenome.build({"template": "fungal_mother",
		"genes": ["fungal_spore_sac", "fungal_plague_heart", "fungal_mycelium_net", "insect_compound_eye"]}, db)
	var prominent := 0
	for p: Dictionary in vg.parts:
		if p.prominent:
			prominent += 1
	check(prominent <= Defs.VISUAL_MAX_PROMINENT, "at most %d prominent parts" % Defs.VISUAL_MAX_PROMINENT)


func test_leap_when_overwhelmed() -> void:
	var heavy: Array = []
	for i in 7:
		heavy.append({"id": "t%d" % i, "race": "insect", "slot": "core", "stability": 4, "visual": {"part": "none", "layer": "chitin"}})
	var vg := VisualGenome.build({"template": "human_militia", "genes": heavy}, db)
	check(vg.leaped, "foreign weight >= 2x base -> skeleton leap")
	check_eq(vg.body_plan, "hexapod", "leapt to insect body plan")


func test_species_name() -> void:
	var vg := VisualGenome.build({"template": "human_scout", "genes": ["insect_compound_eye", "insect_venom_gland"]}, db)
	check(str(vg.name).ends_with("猎使"), "name ends with role word: %s" % vg.name)
	check(str(vg.name).length() >= 3, "name is composed: %s" % vg.name)
