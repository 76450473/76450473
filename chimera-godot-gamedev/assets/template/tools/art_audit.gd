extends SceneTree
## Which art is still missing, with a ready-to-paste prompt for each asset.
##   godot --headless --path . --script res://tools/art_audit.gd
## Every run rewrites ALL three files, so they never go stale after a style change or new content:
##   docs/ART_TODO.md (missing only) · docs/ART_PROMPTS.md (every asset) · docs/ART_PROMPTS.txt (every asset, plain text)
##   ... -- p1   -> ART_TODO.md limited to priority 1   (legacy "-- full" / "-- txt" are accepted and ignored)
## The list is derived from game data, so new genes/biomes/cards show up here automatically.

const INTRO := """怎么用（工作区里有 GPTapi.txt 时，这些都由 Claude 自动完成，你只需要在审核页面复审）：
1. 用任意 AI 生图工具（Midjourney / Stable Diffusion / 即梦 / 通义万相 / GPT 图像 …）复制下面的提示词生成。
   Midjourney：建议用二次元模型（--niji 6），末尾加 `--ar 比例 --no 反向提示词`；出了满意的第一张后，后续都加 `--sref 它的链接`，保持风格统一。
   没有反向提示词栏的工具（GPT 图像等）：在提示词末尾加 `Avoid: 反向提示词`。
   即梦、通义万相、可灵：可以直接粘贴英文提示词；请关闭"智能扩写/提示词优化"，否则会自动加背景。
   能直接输出透明背景 PNG 的工具最好，导入时会自动识别。
2. 每张图按「保存为」的文件名保存（png/jpg/webp 都行，名字对了最省事），放进工作区的 `美术资产/已通过/`，或者打包成 zip 放在工作区。
3. 背景要求：角色立绘、部件、Boss 用**纯白平底**（或透明），图标用**纯黑平底**；主体边缘要清楚，这样才能自动抠图。
   所有角色都是成年人，服装性感但不裸露。
4. 写一行 credits（用的工具/模型 + 授权，例如：Midjourney v7，付费订阅可商用），放进资产包的 credits.txt。
5. 对 Claude 说「导入美术」。它会处理、截图检查，并告诉你哪些要重做、还缺什么。
缺的资产不影响游戏运行——会自动用程序化占位美术代替。"""


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var only_p1 := args.has("p1")
	var db := GameData.load_default()
	var entries := ArtManifest.build(db)
	var counts := {}
	var missing: Array = []
	for e: Dictionary in entries:
		var p := int(e.priority)
		if not counts.has(p):
			counts[p] = [0, 0]
		counts[p][1] += 1
		if ArtManifest.is_present(e):
			counts[p][0] += 1
		elif not only_p1 or p == 1:
			missing.append(e)
	var summary := PackedStringArray()
	var keys: Array = counts.keys()
	keys.sort()
	for p: int in keys:
		summary.append("P%d %d/%d" % [p, counts[p][0], counts[p][1]])
	var intro := "进度：" + "　".join(summary) + "\n\n" + INTRO
	_write("docs/ART_TODO.md", ArtManifest.to_markdown(missing, "缺失的美术资产（%d 项）" % missing.size(), intro))
	_write("docs/ART_PROMPTS.md", ArtManifest.to_markdown(entries, "美术资产提示词（全部 %d 项）" % entries.size(), intro))
	_write("docs/ART_PROMPTS.txt", ArtManifest.to_text(entries))
	var out_rel := "docs/ART_TODO.md"
	print("art coverage: ", "  ".join(summary))
	print("missing: %d  -> %s" % [missing.size(), out_rel])
	for e: Dictionary in missing.slice(0, 12):
		print("  P%d  %-28s %s" % [e.priority, e.id, e.cn])
	if missing.size() > 12:
		print("  ... (%d more in %s)" % [missing.size() - 12, out_rel])
	quit(0)


func _write(rel: String, text: String) -> void:
	var path := ProjectSettings.globalize_path("res://" + rel)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text if text.ends_with("\n") else text + "\n")
	f.close()
