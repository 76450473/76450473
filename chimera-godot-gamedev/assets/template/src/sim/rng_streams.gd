class_name RngStreams
extends RefCounted
## Independent, seeded RNG streams. Rule: every random decision names its stream,
## so rerolling a reward never changes the map, combat, or enemy generation.
## Same run_seed => identical run (daily seeds, bug repro, replays, balance sims).

const STREAMS := ["map", "reward", "combat", "fusion", "enemy", "event", "visual"]

var run_seed: int = 0
var _streams: Dictionary = {}


func _init(seed_value: int = 0) -> void:
	reseed(seed_value)


func reseed(seed_value: int) -> void:
	run_seed = seed_value
	_streams.clear()
	for stream_name: String in STREAMS:
		var r := RandomNumberGenerator.new()
		r.seed = hash("%d:%s" % [seed_value, stream_name])
		_streams[stream_name] = r


func stream(stream_name: String) -> RandomNumberGenerator:
	assert(_streams.has(stream_name), "unknown rng stream " + stream_name)
	return _streams[stream_name]


## Child generator for one sub-task (e.g. one combat) without consuming the parent much.
func fork(stream_name: String) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = stream(stream_name).randi()
	return r


func save_state() -> Dictionary:
	var states := {}
	for stream_name: String in _streams:
		states[stream_name] = str((_streams[stream_name] as RandomNumberGenerator).state)
	return {"run_seed": run_seed, "states": states}


func load_state(d: Dictionary) -> void:
	reseed(int(d.get("run_seed", 0)))
	var states: Dictionary = d.get("states", {})
	for stream_name: String in states:
		if _streams.has(stream_name):
			(_streams[stream_name] as RandomNumberGenerator).state = int(states[stream_name])


static func seed_from_text(text: String) -> int:
	return hash(text.strip_edges().to_lower())


## Deterministic weighted pick. items/weights same length; returns index or -1.
static func weighted_index(rng: RandomNumberGenerator, weights: Array) -> int:
	var total: float = 0.0
	for w: float in weights:
		total += max(w, 0.0)
	if total <= 0.0:
		return -1
	var roll: float = rng.randf() * total
	for i in weights.size():
		roll -= max(float(weights[i]), 0.0)
		if roll < 0.0:
			return i
	return weights.size() - 1


## Fisher-Yates using the given stream (Array.shuffle() uses the global RNG — never use it in sim code).
static func shuffle(rng: RandomNumberGenerator, arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
