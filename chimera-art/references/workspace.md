# 工作区和进度文件

工作区就是用户在 Codex 里打开的美术文件夹（例如 `D:\chimera_art`，一开始是空的）。本技能装在 Codex 的技能文件夹里（通常是 `%USERPROFILE%\.codex\skills\chimera-art\`），只从那里读，不往那里写。下面的路径都相对于工作区根目录，文件夹名只用英文。

```
review.html            审核页（从技能的 assets/review.html 复制，不要改）
art_pack/              通过的图，文件名和清单完全一致；还有 credits.txt
candidates/            所有候选图：<id>__v1.png、<id>__v2.png ……
style/                 选画风的三张图 style_A/B/C.png；选中的复制成 style_ref.png
outbox/                打好的 zip：art_pack.zip（全部）、fix_01.zip、fix_02.zip ……（补图）
state/assets.json      清单（第一次从技能的 assets/assets.json 复制）
state/progress.json    进度
state/review_data.js   当前这一批的审核数据（每批重写）
state/merged/          合并过的旧 ART_ASSETS.json
ART_ASSETS.json        （可能有）用户放进来的新清单，见 flow.md「换清单」
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
  "review": { "id": "", "items": [] },
  "review_void": [],
  "fix": 0,
  "fix_job": null,
  "refs_broken": false,
  "refs_broken_date": "",
  "pending_ref_call": "",
  "items": {
    "part_sac": { "n": 13, "status": "todo", "candidates": [], "pick": 0, "notes": [], "tries": 0 }
  },
  "skipped_reason": {},
  "images_generated": 0
}
```

- `phase`：`style`（选画风）→ `anchor`（定调批）→ `bulk`（批量）→ `done`。
- `items.<id>.status`：`todo` 待做 · `review` 已出图等用户审 · `redo` 要重画 · `approved` 已通过（已复制进 art_pack）· `skipped` 跳过。
- `review`：当前这一批的 `id` 和编号列表，**开始出图时就写好**。`review_void`：清单升级时作废的批次名（flow.md「换清单」），没有就是空列表。
- `candidates` 存候选图的相对路径，`pick` 是首选的下标；`notes` 是修改意见（英文），重画时都要用上。
- `fix_job`：正在做的补图任务（flow.md「补图」），没有时为 null。
- `pending_ref_call`：带参考图出图前写上这一项的 id，出完马上清空（见 prompting.md 第 4 节）。
- 每出一张图 `images_generated` 加 1。每完成一项就保存一次。

## 生成的图放到哪里

`image_gen` 把图存在 Codex 自己的文件夹（`$CODEX_HOME/generated_images/…`，通常是用户目录下的 `.codex\generated_images\`），工具结果里会给出路径。每出一张，马上复制到 `candidates/<id>__v<k>.png`。不要把只存在 Codex 文件夹里的图写进审核页。

## 常用命令

Windows（PowerShell 5.1，一般没有 Python）：

```powershell
New-Item -ItemType Directory -Force art_pack, candidates, style, outbox, state, state\merged | Out-Null
Get-Content -Raw -Encoding UTF8 state\progress.json
Copy-Item -LiteralPath "<image_gen 给的路径>" -Destination "candidates\part_sac__v1.png"
Copy-Item -LiteralPath "candidates\part_sac__v1.png" -Destination "art_pack\part_sac.png" -Force
Compress-Archive -Path art_pack\* -DestinationPath outbox\art_pack.zip -Force
Compress-Archive -LiteralPath art_pack\part_sac.png, art_pack\credits.txt -DestinationPath outbox\fix_01.zip -Force
(Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
```

macOS / Linux：

```sh
mkdir -p art_pack candidates style outbox state/merged
cp "<image_gen 给的路径>" candidates/part_sac__v1.png
(cd art_pack && zip -q -j ../outbox/art_pack.zip ./*)
```

- 读文本一律 `-Encoding UTF8`（不加会把中文读成乱码）。写 JSON 和 `state/review_data.js` 用文件编辑工具，或 `ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8`（不加 `-Depth 10` 会把嵌套的数组截断成 "System.Object[]"）。
- `Compress-Archive` 只压平铺的文件，不要压子文件夹。
- 不要用命令打开审核页：告诉用户 `review.html` 的完整路径，请他双击打开。
