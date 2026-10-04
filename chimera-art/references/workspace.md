# 工作区和进度文件

工作区就是用户在 Codex 里打开的那个美术文件夹（技能装在它里面的 `.agents/skills/chimera-art/`，或者装在用户目录）。所有路径都相对于工作区根目录，文件夹名只用英文。

```
review.html            审核页（从技能的 assets/review.html 复制，不要改）
review_data.js         当前这一批的审核数据（每批重写）
art_pack/              通过的图，文件名和清单完全一致；还有 credits.txt
candidates/            所有候选图：<id>__v1.png、<id>__v2.png ……
style/                 选画风的三张图 style_A.png / style_B.png / style_C.png，选中的复制成 style_ref.png
outbox/                打好的 zip：art_pack.zip（全部）、fix_01.zip、fix_02.zip ……（补图）
state/assets.json      清单（第一次从技能的 assets/assets.json 复制）
state/progress.json    进度
ART_ASSETS.json        （可能有）用户放进来的新清单，见 SKILL.md「文件」
美术资产清单与提示词.txt、Codex使用说明.txt   给用户看的，不用管
```

## 第一次"开始"时准备

1. 建好上面的文件夹，复制 `review.html` 和 `state/assets.json`。
2. 在 `art_pack/credits.txt` 写一行（UTF-8）：`Codex 内置图像生成（ChatGPT 订阅）`
3. 新建 `state/progress.json`（格式见下），所有项状态为 `todo`。
4. 用一两句话告诉用户接下来会发生什么："先出 3 种画风给你选，选好后做 7 张定调图，然后每批 8 张左右给你审。"

## progress.json

```json
{
  "version": 1,
  "phase": "style",
  "style": { "choice": "", "clause": "", "note_en": "", "ref": "style/style_ref.png" },
  "batch": 0,
  "fix": 0,
  "review": { "id": "", "items": [] },
  "items": {
    "part_sac": { "n": 13, "status": "todo", "candidates": [], "pick": 0, "notes": [], "tries": 0 }
  },
  "skipped_reason": {},
  "images_generated": 0
}
```

- `phase`：`style`（选画风）→ `anchor`（定调批）→ `bulk`（批量）→ `done`。补图时临时是 `fix`，做完回到原来的阶段。
- `items.<id>.status`：`todo` 待做 · `review` 已出图等用户审 · `redo` 要重画 · `approved` 已通过（已复制进 art_pack）· `skipped` 跳过。
- `review`：当前审核页这一批的 `id` 和编号列表。用户还没贴回审核结果时，"继续"要先提醒他审这一批，不要开新批。
- `candidates` 里存候选图的相对路径，`pick` 是首选的下标；`notes` 是用户和你的修改意见（英文），重画时都要用上。
- 每出一张图 `images_generated` 加 1。每完成一项就保存一次文件。

## 生成的图放到哪里

`image_gen` 把图存在 Codex 自己的文件夹里（`$CODEX_HOME/generated_images/…`，通常是用户目录下的 `.codex/generated_images/`），工具结果里会给出路径。每出一张，马上复制到 `candidates/<id>__v<k>.png`。不要把只存在 Codex 文件夹里的图写进审核页。

## 常用命令

Windows（PowerShell）：

```powershell
New-Item -ItemType Directory -Force art_pack, candidates, style, outbox, state | Out-Null
Copy-Item -LiteralPath "<image_gen 给的路径>" -Destination "candidates\part_sac__v1.png"
Copy-Item -LiteralPath "candidates\part_sac__v1.png" -Destination "art_pack\part_sac.png" -Force
Compress-Archive -Path art_pack\* -DestinationPath outbox\art_pack.zip -Force
Compress-Archive -LiteralPath art_pack\part_sac.png, art_pack\credits.txt -DestinationPath outbox\fix_01.zip -Force
Start-Process .\review.html
```

macOS / Linux：

```sh
mkdir -p art_pack candidates style outbox state
cp "<image_gen 给的路径>" candidates/part_sac__v1.png
(cd art_pack && zip -q -j ../outbox/art_pack.zip ./*)
open review.html        # Linux: xdg-open review.html
```

写 JSON 和 `review_data.js` 时用 UTF-8（PowerShell 5 里用 `Set-Content -Encoding UTF8`，或者直接用你的文件编辑工具）。
打不开审核页（沙盒不让启动浏览器）时，告诉用户："请在文件夹里双击 review.html。"
