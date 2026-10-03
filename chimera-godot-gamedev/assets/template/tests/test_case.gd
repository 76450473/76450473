class_name TestCase
extends RefCounted
## Minimal dependency-free test base. Methods named test_* are run by tests/run_tests.gd.
## (GUT / gdUnit4 can be added later; this keeps CI and AI loops working with zero addons.)

var failures: PackedStringArray = []
var assertions: int = 0
var db: GameData


func before_all() -> void:
	db = GameData.load_default()


func check(cond: bool, msg: String) -> void:
	assertions += 1
	if not cond:
		failures.append(msg)


func check_eq(actual: Variant, expected: Variant, msg: String) -> void:
	assertions += 1
	if typeof(actual) != typeof(expected) and not (_num(actual) and _num(expected)):
		failures.append("%s: expected %s (%s) got %s (%s)" % [msg, expected, type_string(typeof(expected)), actual, type_string(typeof(actual))])
	elif actual != expected:
		failures.append("%s: expected %s got %s" % [msg, expected, actual])


func _num(v: Variant) -> bool:
	return typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT


func rng(seed_value: int = 1) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r
