class_name UnitState
extends RefCounted
## One piece on the board during a combat. Built from a unit spec by UnitBuilder.

var uid: int = 0
var side: int = 0  # 0 = player, 1 = enemy
var lane: int = 0  # 0..Defs.LANES-1
var row: int = 0  # 0 front, 1 back
var template_id: String = ""
var race: String = ""
var display_name: String = ""
var max_hp: int = 1
var hp: int = 1
var atk: int = 0
var spd: int = 0
var armor: int = 0
var statuses: Dictionary = {}  # status id -> stacks
var effects: Array = []  # effect dicts, each with "_gene" = source gene id/name
var gene_ids: PackedStringArray = []
var alive: bool = true
var summoned: bool = false
var analyzed: bool = false


func stacks(status: String) -> int:
	return int(statuses.get(status, 0))


func add_status(status: String, amount: int) -> void:
	var v := stacks(status) + amount
	if v <= 0:
		statuses.erase(status)
	else:
		statuses[status] = v


func is_adjacent(other: UnitState) -> bool:
	return other.side == side and absi(other.lane - lane) + absi(other.row - row) == 1


func snapshot() -> Dictionary:
	return {"uid": uid, "side": side, "lane": lane, "row": row, "template": template_id,
		"name": display_name, "hp": hp, "max_hp": max_hp, "atk": atk, "spd": spd,
		"armor": armor, "statuses": statuses.duplicate(), "alive": alive}
