extends TestCase
## Content integrity: every id/enum referenced in data/*.json exists, powers are in band.


func test_data_validates() -> void:
	var errs := db.validate()
	for e in errs:
		check(false, e)
	check(errs.is_empty(), "data has %d problems" % errs.size())


func test_minimum_content() -> void:
	check(db.races.size() >= 2, "need >= 2 races")
	check(db.genes.size() >= 12, "need >= 12 genes")
	for r: String in db.races:
		if db.races[r].get("playable", false):
			check(db.recruitable_units(r).size() >= 1, "playable race %s has no recruitable unit" % r)


func test_every_gene_describes() -> void:
	for g: Dictionary in db.genes.values():
		var text := GeneMath.describe_gene(g, db.unit_names())
		check(text != "" and not text.contains("?"), "gene %s description: '%s'" % [g.id, text])
