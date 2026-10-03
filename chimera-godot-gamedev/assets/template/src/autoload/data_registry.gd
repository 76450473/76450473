extends Node
## Autoload `Data`: game-wide access to content as `Data.db` (a GameData).
## Tests and tools should build their own GameData via GameData.load_default().

var db: GameData


func _init() -> void:
	db = GameData.load_default()
	if OS.is_debug_build():
		var errs := db.validate()
		for e in errs:
			push_error("[data] " + e)
