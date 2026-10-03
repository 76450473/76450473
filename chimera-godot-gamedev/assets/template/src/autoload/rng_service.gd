extends Node
## Autoload `Rng`: the run-wide RngStreams. Sim code never calls randi()/randf()/shuffle()
## directly; it receives a RandomNumberGenerator from here (or from a test).

var streams: RngStreams = RngStreams.new(0)


func new_run(seed_value: int = -1) -> int:
	if seed_value < 0:
		var r := RandomNumberGenerator.new()
		r.randomize()
		seed_value = r.randi()
	streams.reseed(seed_value)
	return seed_value


func stream(stream_name: String) -> RandomNumberGenerator:
	return streams.stream(stream_name)
