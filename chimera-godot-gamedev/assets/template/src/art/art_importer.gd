class_name ArtImporter
extends RefCounted
## Turns a user-supplied (AI-generated) image into a game-ready asset. Pure + testable.
##   palette : remove flat background -> trim -> desaturate (keep saturated "glow" pixels as accent)
##   cutout  : remove flat background -> trim (keeps colors)
##   mono    : white symbol on black (or black on white) -> white silhouette with alpha
##   color   : no background removal; resized (cover = fill + center crop, fit = contain)
## Generators rarely output transparency, so prompts ask for a FLAT pure white / black
## background and a thick dark outline; the flood fill starts at the image border and
## therefore never eats highlights enclosed by the outline.

const BG_TOLERANCE := 38  # per-channel 0..255
const ACCENT_SATURATION := 0.2


static func process(src: Image, entry: Dictionary) -> Dictionary:
	var warnings: PackedStringArray = []
	var img: Image = src.duplicate()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var canvas: Array = entry.get("canvas", [256, 256])
	var tw := int(canvas[0])
	var th := int(canvas[1])
	var mode: String = entry.get("mode", "palette")
	if maxi(img.get_width(), img.get_height()) < maxi(tw, th) * 0.6:
		warnings.append("分辨率偏低（%dx%d），建议至少 %s" % [img.get_width(), img.get_height(), entry.get("gen_size", "1024×1024")])
	var work_max := maxi(tw, th) * 2
	if maxi(img.get_width(), img.get_height()) > work_max:
		var k := float(work_max) / maxi(img.get_width(), img.get_height())
		img.resize(maxi(1, int(img.get_width() * k)), maxi(1, int(img.get_height() * k)), Image.INTERPOLATE_LANCZOS)
	var removed := -1.0
	if mode == "palette" or mode == "cutout":
		removed = remove_background(img, bool(entry.get("hollow", false)))
		if removed >= 0.0 and removed < 0.03:
			warnings.append("几乎没有去掉背景：请确认是纯白平底背景、主体有深色描边")
		elif removed > 0.995:
			warnings.append("几乎整张图都被当成了背景：主体太小，或颜色和背景太接近")
	elif mode == "mono":
		mono_from_luminance(img)
	if mode != "color":
		var rect := img.get_used_rect()
		if rect.size.x <= 0 or rect.size.y <= 0:
			return {"error": "处理后图片为空（全部透明）", "warnings": warnings}
		if maxi(rect.size.x, rect.size.y) < maxi(tw, th) * 0.5:
			warnings.append("主体在原图里只有 %dpx，放大后会发糊：生成时让主体占满画面的 60%% 以上" % maxi(rect.size.x, rect.size.y))
		img = img.get_region(rect)
	if mode == "palette":
		var colored := desaturate_keep_accent(img)
		var limit := 0.75 if str(entry.get("accent", "")) != "" else 0.25
		if colored > limit:
			warnings.append("彩色面积 %.0f%% 偏大：调色模式要求灰度图（只有发光部位用鲜绿）。重新生成时强调 strictly grayscale，或者让 Claude 把这张改成彩色模式" % (colored * 100.0))
	if str(entry.get("fit", "fit")) == "cover":
		cover_resize(img, tw, th)
	else:
		fit_resize(img, tw, th)
	return {"image": img, "pivot": anchor_pivot(img.get_size(), entry.get("anchor", "center")),
		"warnings": warnings, "removed": removed}


## Flood-fills the flat background from the border (and from the center if hollow).
## Returns the removed fraction, or -1 if the image already had a transparent border.
static func remove_background(img: Image, hollow: bool = false) -> float:
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	var border_total := 0
	var border_clear := 0
	for x in range(0, w, maxi(1, w / 64)):
		for y: int in [0, h - 1]:
			border_total += 1
			if data[(y * w + x) * 4 + 3] < 128:
				border_clear += 1
	if border_clear * 2 > border_total:
		return -1.0
	var bg := _corner_color(data, w, h)
	var visited := PackedByteArray()
	visited.resize(w * h)
	var seeds := PackedInt32Array()
	for x in w:
		seeds.append(x)
		seeds.append((h - 1) * w + x)
	for y in h:
		seeds.append(y * w)
		seeds.append(y * w + w - 1)
	var removed := _flood(data, w, h, visited, seeds, bg)
	if hollow:
		var c := (h / 2) * w + w / 2
		var center := Color8(data[c * 4], data[c * 4 + 1], data[c * 4 + 2])
		if center.get_luminance() > 0.8:
			removed += _flood(data, w, h, visited, PackedInt32Array([c]), center)
	# clear + feather
	for i in w * h:
		if visited[i] == 1:
			data[i * 4] = 12
			data[i * 4 + 1] = 12
			data[i * 4 + 2] = 12
			data[i * 4 + 3] = 0
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			var i := y * w + x
			if visited[i] == 0 and (visited[i - 1] == 1 or visited[i + 1] == 1 or visited[i - w] == 1 or visited[i + w] == 1):
				data[i * 4 + 3] = int(data[i * 4 + 3] * 0.55)
	img.set_data(w, h, false, Image.FORMAT_RGBA8, data)
	return float(removed) / float(w * h)


static func _flood(data: PackedByteArray, w: int, h: int, visited: PackedByteArray,
		seeds: PackedInt32Array, bg: Color) -> int:
	var br := int(bg.r8)
	var bgc := int(bg.g8)
	var bb := int(bg.b8)
	var queue := PackedInt32Array()
	var count := 0
	for s in seeds:
		if visited[s] == 0 and _near(data, s, br, bgc, bb):
			visited[s] = 1
			queue.append(s)
	var head := 0
	while head < queue.size():
		var i := queue[head]
		head += 1
		count += 1
		var x := i % w
		var y := i / w
		if x > 0 and visited[i - 1] == 0 and _near(data, i - 1, br, bgc, bb):
			visited[i - 1] = 1
			queue.append(i - 1)
		if x < w - 1 and visited[i + 1] == 0 and _near(data, i + 1, br, bgc, bb):
			visited[i + 1] = 1
			queue.append(i + 1)
		if y > 0 and visited[i - w] == 0 and _near(data, i - w, br, bgc, bb):
			visited[i - w] = 1
			queue.append(i - w)
		if y < h - 1 and visited[i + w] == 0 and _near(data, i + w, br, bgc, bb):
			visited[i + w] = 1
			queue.append(i + w)
	return count


static func _near(data: PackedByteArray, i: int, r: int, g: int, b: int) -> bool:
	var o := i * 4
	return absi(data[o] - r) <= BG_TOLERANCE and absi(data[o + 1] - g) <= BG_TOLERANCE and absi(data[o + 2] - b) <= BG_TOLERANCE


static func _corner_color(data: PackedByteArray, w: int, h: int) -> Color:
	var r := 0
	var g := 0
	var b := 0
	var n := 0
	for cy: int in [0, h - 4]:
		for cx: int in [0, w - 4]:
			for dy in 4:
				for dx in 4:
					var o := ((cy + dy) * w + cx + dx) * 4
					r += data[o]
					g += data[o + 1]
					b += data[o + 2]
					n += 1
	return Color8(r / n, g / n, b / n)


## Grayscale everything except clearly saturated pixels (the "glow" accent areas).
## Returns the fraction of opaque pixels that stayed colored.
static func desaturate_keep_accent(img: Image) -> float:
	var data := img.get_data()
	var opaque := 0
	var colored := 0
	for i in img.get_width() * img.get_height():
		var o := i * 4
		if data[o + 3] < 16:
			continue
		opaque += 1
		var r := data[o]
		var g := data[o + 1]
		var b := data[o + 2]
		var mx := maxi(r, maxi(g, b))
		var mn := mini(r, mini(g, b))
		if float(mx - mn) / 255.0 >= ACCENT_SATURATION:
			colored += 1
			continue
		var lum := int(0.299 * r + 0.587 * g + 0.114 * b)
		data[o] = lum
		data[o + 1] = lum
		data[o + 2] = lum
	img.set_data(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8, data)
	return float(colored) / maxf(1.0, opaque)


## White silhouette whose alpha comes from luminance contrast against the background.
static func mono_from_luminance(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var data := img.get_data()
	# Transparent PNG (tool exported with alpha): the shape IS the alpha channel.
	var clear_bg := data[3] < 128 and data[(w - 1) * 4 + 3] < 128 and data[((h - 1) * w) * 4 + 3] < 128 \
		and data[(w * h - 1) * 4 + 3] < 128
	var dark_bg := _corner_color(data, w, h).get_luminance() < 0.5
	for i in w * h:
		var o := i * 4
		var lum := (0.299 * data[o] + 0.587 * data[o + 1] + 0.114 * data[o + 2]) / 255.0
		var a := lum if dark_bg else 1.0 - lum
		a = clampf((a - 0.2) / 0.6, 0.0, 1.0) * data[o + 3] / 255.0
		if clear_bg:
			a = data[o + 3] / 255.0
		data[o] = 255
		data[o + 1] = 255
		data[o + 2] = 255
		data[o + 3] = int(a * 255.0)
	img.set_data(w, h, false, Image.FORMAT_RGBA8, data)


static func fit_resize(img: Image, tw: int, th: int) -> void:
	var k := minf(float(tw) / img.get_width(), float(th) / img.get_height())
	img.resize(maxi(1, int(round(img.get_width() * k))), maxi(1, int(round(img.get_height() * k))), Image.INTERPOLATE_LANCZOS)


static func cover_resize(img: Image, tw: int, th: int) -> void:
	var k := maxf(float(tw) / img.get_width(), float(th) / img.get_height())
	img.resize(maxi(tw, int(ceil(img.get_width() * k))), maxi(th, int(ceil(img.get_height() * k))), Image.INTERPOLATE_LANCZOS)
	var x := (img.get_width() - tw) / 2
	var y := (img.get_height() - th) / 2
	var cropped := img.get_region(Rect2i(x, y, tw, th))
	img.copy_from(cropped)


static func anchor_pivot(size: Vector2i, anchor: String) -> Vector2:
	match anchor:
		"bottom_center":
			return Vector2(size.x / 2.0, size.y)
		"top_center":
			return Vector2(size.x / 2.0, 0)
		"left_center":
			return Vector2(0, size.y / 2.0)
		"right_center":
			return Vector2(size.x, size.y / 2.0)
		_:
			return Vector2(size) / 2.0


## Display scale (creature-local px per image px) for parts and bodies.
static func display_scale(entry: Dictionary, size: Vector2i) -> float:
	match str(entry.get("category", "")):
		"part":
			return float(entry.get("height", 20)) / maxf(1.0, size.y)
		"body":
			var dim: float = size.x if entry.get("body_fit", "height") == "width" else size.y
			return float(entry.get("size", 130)) / maxf(1.0, dim)
	return 1.0
