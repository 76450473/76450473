extends TestCase


func test_same_seed_same_sequence() -> void:
	var a := RngStreams.new(42)
	var b := RngStreams.new(42)
	for i in 20:
		check_eq(a.stream("combat").randi(), b.stream("combat").randi(), "combat stream draw %d" % i)


func test_streams_are_independent() -> void:
	var a := RngStreams.new(7)
	var b := RngStreams.new(7)
	for i in 50:
		a.stream("reward").randi()  # consuming rewards must not move the map stream
	check_eq(a.stream("map").randi(), b.stream("map").randi(), "map unaffected by reward draws")


func test_save_load_state() -> void:
	var a := RngStreams.new(99)
	a.stream("enemy").randi()
	var saved := a.save_state()
	var next := a.stream("enemy").randi()
	var b := RngStreams.new(0)
	b.load_state(saved)
	check_eq(b.stream("enemy").randi(), next, "restored stream continues identically")


func test_weighted_index() -> void:
	var r := rng(3)
	var counts := [0, 0, 0]
	for i in 3000:
		counts[RngStreams.weighted_index(r, [1.0, 0.0, 3.0])] += 1
	check_eq(counts[1], 0, "zero weight never picked")
	check(counts[2] > counts[0] * 2, "weight 3 picked ~3x weight 1 (%s)" % [counts])
