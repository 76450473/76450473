class_name CombatSim
extends RefCounted
## Deterministic, headless combat. No Nodes, no global RNG, no autoloads.
## The view layer replays `events`; balance tools run thousands of these per second.
##
## Board: each side has Defs.LANES lanes x Defs.ROWS rows (row 0 = front).
## Round:  begin_round()  -> on_round_start triggers, energy refresh
##         play_card()*   -> player (or AI) spends energy on tactic cards
##         resolve_round() -> units act by speed; statuses tick; erosion; win check
##
##   var sim := CombatSim.new(db, rng, biome.get("rules", {}))
##   sim.add_team(player_specs, 0)
##   sim.add_team(enemy_specs, 1)
##   var winner := sim.run_auto()   # 0 player, 1 enemy, -1 draw

var db: GameData
var rng: RandomNumberGenerator
var rules: Dictionary = {}
var units: Array[UnitState] = []
var events: Array[Dictionary] = []
var round_num: int = 0
var winner: int = -2  # -2 running, -1 draw, 0 player, 1 enemy
var energy: int = 0
var hit_trigger_cap: bool = false
var _next_uid: int = 1
var _depth: int = 0
var _triggers_this_round: int = 0


func _init(p_db: GameData, p_rng: RandomNumberGenerator, p_rules: Dictionary = {}) -> void:
	db = p_db
	rng = p_rng
	rules = p_rules


# ---------------------------------------------------------------- setup

func add_team(specs: Array, side: int) -> void:
	for spec: Dictionary in specs:
		add_unit(spec, side)


func add_unit(spec: Dictionary, side: int) -> UnitState:
	var lane := int(spec.get("lane", 0))
	var row := int(spec.get("row", 0))
	if unit_at(side, lane, row) != null:
		var free := _free_slot(side, null)
		if free.x < 0:
			return null
		lane = free.x
		row = free.y
	var placed := spec.duplicate()
	placed["lane"] = lane
	placed["row"] = row
	var u := UnitBuilder.build(placed, db, side, _next_uid)
	if side == 1:
		u.max_hp = int(round(u.max_hp * Defs.ENEMY_HP_MULT))
		u.hp = u.max_hp
	_next_uid += 1
	units.append(u)
	return u


func initial_snapshot() -> Array:
	var out: Array = []
	for u in units:
		out.append(u.snapshot())
	return out


# ---------------------------------------------------------------- queries

func is_over() -> bool:
	return winner != -2


func living(side: int) -> Array[UnitState]:
	var out: Array[UnitState] = []
	for u in units:
		if u.alive and u.side == side:
			out.append(u)
	return out


func unit_by_uid(uid: int) -> UnitState:
	for u in units:
		if u.uid == uid:
			return u
	return null


func unit_at(side: int, lane: int, row: int) -> UnitState:
	for u in units:
		if u.alive and u.side == side and u.lane == lane and u.row == row:
			return u
	return null


# ---------------------------------------------------------------- round flow

func begin_round() -> void:
	if is_over():
		return
	round_num += 1
	_triggers_this_round = 0
	energy = Defs.ENERGY_PER_ROUND
	_emit({"type": "round_start", "round": round_num})
	for u in _action_order():
		if u.alive:
			_fire(u, "on_round_start", null)
	_check_end()


func play_card(card: Dictionary, side: int, target_uid: int = -1) -> bool:
	if is_over():
		return false
	var cost := int(card.get("cost", 0))
	if cost > energy:
		return false
	var kind: String = card.get("target", "none")
	var targets := _card_targets(kind, side, target_uid)
	if kind.begins_with("chosen") and targets.is_empty():
		return false
	energy -= cost
	_emit({"type": "card", "card": card.get("id", ""), "side": side, "target": target_uid})
	for eff: Dictionary in card.get("effects", []):
		var action: String = eff.get("action", "")
		if action == "summon":
			_summon(side, eff.get("unit", ""), int(eff.get("amount", 1)), null)
		elif action == "analyze":
			for t in targets:
				t.analyzed = true
				_emit({"type": "analyze", "dst": t.uid})
		else:
			for t in targets:
				_apply(null, t, eff, "card")
	_check_end()
	return true


func resolve_round() -> void:
	if is_over():
		return
	for u in _action_order():
		if is_over():
			break
		if not u.alive:
			continue
		if u.stacks("stun") > 0:
			u.add_status("stun", -1)
			_emit({"type": "stunned", "uid": u.uid})
			continue
		var target := _lane_target(u)
		if target == null:
			continue
		_emit({"type": "attack", "src": u.uid, "dst": target.uid})
		_deal_damage(u, target, u.atk, "attack")
		if u.alive:
			_fire(u, "on_attack", target)
		if target.alive:
			_fire(target, "on_hit", u)
		_check_end()
	if not is_over():
		_round_end()
	_check_end()
	if not is_over() and round_num >= Defs.MAX_ROUNDS:
		winner = -1
		_emit({"type": "end", "winner": winner, "rounds": round_num, "reason": "max_rounds"})


## Runs the whole fight. `policy` (optional) is called as policy.call(sim) after
## begin_round() so an AI / test can play cards.
func run_auto(policy: Callable = Callable()) -> int:
	var guard := 0
	while not is_over() and guard <= Defs.MAX_ROUNDS + 1:
		guard += 1
		begin_round()
		if is_over():
			break
		if policy.is_valid():
			policy.call(self)
		resolve_round()
	return winner


# ---------------------------------------------------------------- internals

func _round_end() -> void:
	for u in _action_order():
		if u.alive:
			_fire(u, "on_round_end", null)
	var poison_bonus := int(rules.get("poison_tick_bonus", 0))
	var regen_bonus := int(rules.get("regen_tick_bonus", 0))
	for u: UnitState in units.duplicate():
		if not u.alive:
			continue
		var p := u.stacks("poison")
		if p > 0:
			u.add_status("poison", -1)
			_lose_hp(u, p + poison_bonus, "poison")
		if not u.alive:
			continue
		var r := u.stacks("regen")
		if r > 0:
			u.add_status("regen", -1)
			_heal(u, maxi(0, r + regen_bonus))
		if u.stacks("vulnerable") > 0:
			u.add_status("vulnerable", -1)
	var erosion_start := int(rules.get("erosion_start", Defs.EROSION_START))
	if round_num >= erosion_start:
		var dmg := round_num - erosion_start + 1
		for u: UnitState in units.duplicate():
			if u.alive:
				_lose_hp(u, dmg, "erosion")
	_emit({"type": "round_end", "round": round_num})


func _action_order() -> Array[UnitState]:
	var keyed: Array = []
	for u in units:
		if u.alive:
			keyed.append([u.spd, rng.randf(), u])
	keyed.sort_custom(func(a: Array, b: Array) -> bool:
		return a[0] > b[0] or (a[0] == b[0] and a[1] > b[1]))
	var out: Array[UnitState] = []
	for k: Array in keyed:
		out.append(k[2])
	return out


func _lane_target(u: UnitState) -> UnitState:
	var enemy_side := 1 - u.side
	for offset: int in [0, -1, 1, -2, 2]:
		var lane := u.lane + offset
		if lane < 0 or lane >= Defs.LANES:
			continue
		for row in Defs.ROWS:
			var t := unit_at(enemy_side, lane, row)
			if t != null:
				return t
	return null


func _neighbors(ref: UnitState) -> Array[UnitState]:
	var out: Array[UnitState] = []
	for u in units:
		if u.alive and u != ref and ref.is_adjacent(u):
			out.append(u)
	return out


func _resolve_targets(src: UnitState, kind: String, other: UnitState) -> Array[UnitState]:
	var out: Array[UnitState] = []
	match kind:
		"self":
			if src.alive:
				out.append(src)
		"other":
			if other != null and other.alive:
				out.append(other)
		"lane_enemy":
			var t := _lane_target(src)
			if t != null:
				out.append(t)
		"enemy_area":
			var ref: UnitState = other if (other != null and other.side != src.side) else _lane_target(src)
			if ref != null:
				if ref.alive:
					out.append(ref)
				out.append_array(_neighbors(ref))
		"ally_area":
			if src.alive:
				out.append(src)
			out.append_array(_neighbors(src))
		"adjacent_allies":
			out.append_array(_neighbors(src))
		"all_enemies":
			out = living(1 - src.side)
		"all_allies":
			out = living(src.side)
		"random_enemy":
			var pool := living(1 - src.side)
			if not pool.is_empty():
				out.append(pool[rng.randi_range(0, pool.size() - 1)])
		"lowest_hp_ally":
			var best: UnitState = null
			for a in living(src.side):
				if best == null or float(a.hp) / a.max_hp < float(best.hp) / best.max_hp:
					best = a
			if best != null:
				out.append(best)
	return out


func _card_targets(kind: String, side: int, target_uid: int) -> Array[UnitState]:
	var out: Array[UnitState] = []
	match kind:
		"chosen_enemy", "chosen_ally":
			var t := unit_by_uid(target_uid)
			var want_side := side if kind == "chosen_ally" else 1 - side
			if t != null and t.alive and t.side == want_side:
				out.append(t)
		"all_enemies":
			out = living(1 - side)
		"all_allies":
			out = living(side)
	return out


func _fire(u: UnitState, trigger: String, other: UnitState) -> void:
	for eff: Dictionary in u.effects:
		if eff.get("trigger", "") != trigger:
			continue
		if _depth >= Defs.TRIGGER_DEPTH_LIMIT or _triggers_this_round >= Defs.TRIGGERS_PER_ROUND_CAP:
			if not hit_trigger_cap:
				hit_trigger_cap = true
				_emit({"type": "trigger_cap", "uid": u.uid, "trigger": trigger})
			return
		_triggers_this_round += 1
		_depth += 1
		_emit({"type": "trigger", "uid": u.uid, "gene": eff.get("_gene", ""), "trigger": trigger})
		if eff.get("action", "") == "summon":
			_summon(u.side, eff.get("unit", ""), int(eff.get("amount", 1)), u)
		else:
			for t in _resolve_targets(u, eff.get("target", "self"), other):
				_apply(u, t, eff, "effect")
		_depth -= 1


func _apply(src: UnitState, t: UnitState, eff: Dictionary, source: String) -> void:
	if not t.alive:
		return
	var n := int(eff.get("amount", 1))
	match str(eff.get("action", "")):
		"damage":
			_deal_damage(src, t, n, source)
		"apply_status":
			var s: String = eff.get("status", "")
			t.add_status(s, n)
			_emit({"type": "status", "dst": t.uid, "status": s, "amount": n})
		"heal":
			_heal(t, n)
		"gain_armor":
			var cap := int(t.max_hp * float(rules.get("armor_cap_mult", 1.0)))
			t.armor = mini(t.armor + n, cap)
			_emit({"type": "armor", "dst": t.uid, "amount": n, "armor": t.armor})
		"buff_atk":
			t.atk += n
			_emit({"type": "buff", "dst": t.uid, "stat": "atk", "amount": n})


func _deal_damage(src: UnitState, t: UnitState, amount: int, source: String) -> void:
	if not t.alive or amount <= 0:
		return
	var dmg := amount
	if t.stacks("vulnerable") > 0:
		dmg = int(ceil(dmg * Defs.VULNERABLE_MULT))
	var absorbed := mini(t.armor, dmg)
	t.armor -= absorbed
	dmg -= absorbed
	t.hp -= dmg
	_emit({"type": "damage", "src": src.uid if src != null else 0, "dst": t.uid,
		"amount": dmg, "absorbed": absorbed, "source": source})
	if t.hp <= 0:
		_kill(t, src)


## Poison / erosion: ignores armor and vulnerable.
func _lose_hp(t: UnitState, amount: int, source: String) -> void:
	if not t.alive or amount <= 0:
		return
	t.hp -= amount
	_emit({"type": "damage", "src": 0, "dst": t.uid, "amount": amount, "absorbed": 0, "source": source})
	if t.hp <= 0:
		_kill(t, null)


func _heal(t: UnitState, amount: int) -> void:
	if not t.alive or amount <= 0:
		return
	var before := t.hp
	t.hp = mini(t.max_hp, t.hp + amount)
	if t.hp != before:
		_emit({"type": "heal", "dst": t.uid, "amount": t.hp - before})


func _kill(t: UnitState, killer: UnitState) -> void:
	if not t.alive:
		return
	t.alive = false
	t.hp = 0
	_emit({"type": "death", "uid": t.uid, "killer": killer.uid if killer != null else 0})
	var inf := t.stacks("infect")
	if inf > 0:
		for n in _neighbors(t):
			n.add_status("poison", inf)
			_emit({"type": "status", "dst": n.uid, "status": "poison", "amount": inf, "source": "infect"})
			if inf > 1:
				n.add_status("infect", inf - 1)
	_fire(t, "on_death", killer)
	if killer != null and killer.alive and killer.side != t.side:
		_fire(killer, "on_kill", t)
	for ally in living(t.side):
		_fire(ally, "on_ally_death", t)


func _summon(side: int, unit_id: String, count: int, near: UnitState) -> void:
	for i in count:
		var slot := _free_slot(side, near)
		if slot.x < 0:
			_emit({"type": "summon_fail", "side": side, "unit": unit_id})
			return
		var u := add_unit({"template": unit_id, "genes": [], "lane": slot.x, "row": slot.y}, side)
		u.summoned = true
		_emit({"type": "summon", "uid": u.uid, "template": unit_id, "side": side,
			"lane": u.lane, "row": u.row})


func _free_slot(side: int, near: UnitState) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_key := 1 << 30
	for lane in Defs.LANES:
		for row in Defs.ROWS:
			if unit_at(side, lane, row) != null:
				continue
			var key: int
			if near != null:
				key = (absi(lane - near.lane) + absi(row - near.row)) * 100 + (1 - row) * 10 + lane
			else:
				key = (1 - row) * 10 + lane  # back row first
			if key < best_key:
				best_key = key
				best = Vector2i(lane, row)
	return best


func _check_end() -> void:
	if winner != -2:
		return
	var p := living(0).size()
	var e := living(1).size()
	if p > 0 and e > 0:
		return
	winner = -1 if (p == 0 and e == 0) else (0 if e == 0 else 1)
	_emit({"type": "end", "winner": winner, "rounds": round_num})


func _emit(ev: Dictionary) -> void:
	events.append(ev)
