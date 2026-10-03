class_name GeneMath
extends RefCounted
## Pure helpers over gene / effect dictionaries (JSON-shaped data).
## Power = the single currency used by fusion, enemy budgets and the data validator.

const STAT_TEXT := {"hp": "生命", "atk": "攻击", "spd": "速度", "armor": "护甲"}


static func element_of(eff: Dictionary) -> String:
	if eff.get("action", "") == "apply_status":
		return str(eff.get("status", ""))
	return str(eff.get("action", ""))


static func is_beneficial(eff: Dictionary) -> bool:
	var action: String = eff.get("action", "")
	if action == "apply_status":
		return Defs.BENEFICIAL_STATUSES.has(eff.get("status", ""))
	return Defs.BENEFICIAL_ACTIONS.has(action)


## Power of one point of `amount` for this effect shape.
static func unit_power(eff: Dictionary) -> float:
	var action: String = eff.get("action", "")
	var base: float = 1.0
	if action == "apply_status":
		base = float(Defs.STATUS_POWER.get(eff.get("status", ""), 1.0))
	else:
		base = float(Defs.ACTION_POWER.get(action, 1.0))
	var target_mult: float = float(Defs.TARGET_MULT.get(eff.get("target", "self"), 1.0))
	var freq: float = float(Defs.TRIGGER_FREQ.get(eff.get("trigger", "on_attack"), 1.0))
	return base * target_mult * freq


static func effect_power(eff: Dictionary) -> float:
	return unit_power(eff) * float(eff.get("amount", 1))


static func stats_power(stats: Dictionary) -> float:
	var p: float = 0.0
	for k: String in stats:
		p += float(Defs.STAT_POWER.get(k, 0.0)) * float(stats[k])
	return p


static func gene_power(gene: Dictionary) -> float:
	var p: float = stats_power(gene.get("stats", {}))
	for eff: Dictionary in gene.get("effects", []):
		p += effect_power(eff)
	return p


## The element that dominates a gene (used for palette accent, fx and naming).
static func main_element(gene: Dictionary) -> String:
	var best := "none"
	var best_p: float = 0.0
	for eff: Dictionary in gene.get("effects", []):
		var p: float = effect_power(eff)
		if p > best_p:
			best_p = p
			best = element_of(eff)
	if best == "none":
		var stats: Dictionary = gene.get("stats", {})
		if stats.has("armor"):
			best = "gain_armor"
		elif stats.has("atk"):
			best = "damage"
	return best


static func describe_effect(eff: Dictionary, unit_names: Dictionary = {}) -> String:
	var n := int(eff.get("amount", 1))
	var t: String = Defs.TARGET_TEXT.get(eff.get("target", "self"), "?")
	var body := ""
	match str(eff.get("action", "")):
		"damage":
			body = "对%s造成%d点伤害" % [t, n]
		"apply_status":
			var s: String = Defs.STATUS_NAME.get(eff.get("status", ""), "?")
			if is_beneficial(eff):
				body = "使%s获得%d层%s" % [t, n, s]
			else:
				body = "对%s施加%d层%s" % [t, n, s]
		"heal":
			body = "为%s恢复%d点生命" % [t, n]
		"gain_armor":
			body = "使%s获得%d点护甲" % [t, n]
		"buff_atk":
			body = "使%s攻击+%d" % [t, n]
		"summon":
			body = "召唤%d只%s" % [n, unit_names.get(eff.get("unit", ""), str(eff.get("unit", "?")))]
		"analyze":
			body = "解析目标的隐藏基因"
		_:
			body = "?"
	var trig: String = Defs.TRIGGER_TEXT.get(eff.get("trigger", ""), "")
	return body if trig == "" else "%s：%s" % [trig, body]


static func describe_gene(gene: Dictionary, unit_names: Dictionary = {}) -> String:
	var parts: PackedStringArray = []
	var stats: Dictionary = gene.get("stats", {})
	for k: String in stats:
		var v := int(stats[k])
		parts.append("%s%s%d" % [STAT_TEXT.get(k, k), "+" if v >= 0 else "", v])
	for eff: Dictionary in gene.get("effects", []):
		parts.append(describe_effect(eff, unit_names))
	return "；".join(parts)
