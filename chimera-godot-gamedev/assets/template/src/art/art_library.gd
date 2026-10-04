class_name ArtLibrary
extends RefCounted
## Runtime lookup of imported art. Missing asset -> {} -> callers fall back to procedural art,
## so the game is always runnable while the art set is incomplete.
## Sidecar <name>.json (written by tools/import_art.gd, hand-tunable):
##   {"pivot": [x, y], "scale": 0.08, "offset": [dx, dy], "rotation": 0.0, "scale_mult": 1.0,
##    "sockets": {"head": [x, y], "head_r": 14, ...}  (bodies only: overrides CreaturePainter.sockets),
##    "mode": "palette" | "cutout"  (cutout = keep the painted colors, no race recolor)}

static var enabled: bool = true
static var _cache: Dictionary = {}


static func lookup(base: String) -> Dictionary:
	if not enabled:
		return {}
	if _cache.has(base):
		return _cache[base]
	var out := {}
	var png := base + ".png"
	if ResourceLoader.exists(png):
		var tex := load(png) as Texture2D
		if tex != null:
			out = {"texture": tex, "pivot": Vector2(tex.get_size()) / 2.0, "scale": 1.0,
				"offset": Vector2.ZERO, "rotation": 0.0, "sockets": {}, "mode": "palette"}
			var meta_path := base + ".json"
			if FileAccess.file_exists(meta_path):
				var meta: Variant = JSON.parse_string(FileAccess.get_file_as_string(meta_path))
				if meta is Dictionary:
					var m: Dictionary = meta
					if m.has("pivot"):
						out.pivot = Vector2(float(m.pivot[0]), float(m.pivot[1]))
					out.scale = float(m.get("scale", 1.0)) * float(m.get("scale_mult", 1.0))
					if m.has("offset"):
						out.offset = Vector2(float(m.offset[0]), float(m.offset[1]))
					out.rotation = deg_to_rad(float(m.get("rotation", 0.0)))
					out.mode = str(m.get("mode", "palette"))
					var socks := {}
					for k: String in m.get("sockets", {}):
						var v: Variant = m.sockets[k]
						if v is Array and (v as Array).size() >= 2:
							socks[k] = Vector2(float(v[0]), float(v[1]))
						elif typeof(v) == TYPE_FLOAT or typeof(v) == TYPE_INT:
							socks[k] = float(v)  # e.g. head_r
					out.sockets = socks
	_cache[base] = out
	return out


static func part(kind: String) -> Dictionary:
	return lookup("res://art/parts/" + kind)


static func body(plan: String) -> Dictionary:
	return lookup("res://art/bodies/" + plan)


## Body art for a VisualGenome: enemies get the villain version (art/bodies/<plan>_enemy.png)
## when it exists, otherwise the normal body of their body plan.
static func body_for(vg: Dictionary) -> Dictionary:
	var plan: String = vg.get("body_plan", "biped")
	if bool(vg.get("enemy", false)):
		var villain := lookup("res://art/bodies/" + plan + "_enemy")
		if not villain.is_empty():
			return villain
	return body(plan)


static func icon(id: String) -> Dictionary:
	return lookup("res://art/icons/" + id)


static func background(biome_id: String) -> Dictionary:
	return lookup("res://art/bg/" + biome_id)


static func clear() -> void:
	_cache.clear()
