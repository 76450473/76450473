---
name: chimera-art
description: 为开源游戏《奇美拉纪元 Chimera Epoch》批量生产 2D 美术资产（约 88 张：角色立绘、反派、基因器官部件、图标、战斗背景、卡图、界面）。只用 Codex 内置的 image_gen 出图（走 ChatGPT 订阅，不用 API key）：先让用户选一次整体画风，再分批出图、自检、预选，生成审核页让用户审，按审核结果重画，合格的图按清单文件名存进 art_pack 并打包成 zip 交给 Claude。也处理 Claude 写的「补图请求」和审核页生成的「审核结果」。Use when the user mentions 奇美拉 / chimera-art / 美术资产 / 补图请求 / 审核结果 / 选画风.
metadata:
  short-description: 奇美拉美术：选画风、出图、审核结果、补图请求、打包（只用内置 image_gen）
---

# 奇美拉纪元 · 美术资产生产

用户不是程序员：用简短中文交流，一次只问一件事，不问技术问题，不让他装软件。
流程：你在这个文件夹里出图 → 他在审核页里审 → 合格的 zip 交给 Claude（用 Godot 做游戏）→ Claude 发现问题写「补图请求」，他再粘贴给你。

**先读 references/game.md**（第一次"开始"时、每次选画风前、自检拿不准时）：这些图在游戏里怎么用、世界观是什么。不了解它，画出来的图可能好看却用不上。

## 红线

- **只用内置 `image_gen` 出图**（一次调用一张）。绝不用 imagegen 技能的 CLI 备用模式、`scripts/image_gen.py`、OpenAI API 或 `OPENAI_API_KEY`，也不向用户要 key。没有 `image_gen` 或出错时按 references/troubleshooting.md 处理。
- **所有角色都是成年人**，服装可以甜美迷人，但不裸露、不色情。被拦截时按 references/prompting.md 第 6 节改写一次。
- **文件名和清单完全一致**（如 `part_sac.png`）。合格的图只放进 `art_pack/`；只有重画的新图通过后才覆盖旧图。
- **进度只存在 `state/progress.json`**，每完成一项就保存。会话随时会中断，下次"继续"要能接上。
- **一个对话里出图满约 12 次**就停下（保存进度），请用户点「新对话」发 `$chimera-art 继续`：图多了 Codex 会变慢、占大量硬盘。不用子代理并行，一张一张来。
- **不要用命令打开浏览器**（沙盒里的窗口用户看不见）：告诉用户 `review.html` 的完整路径，请他双击打开，开着的按 F5 刷新。

## 读写文件（Windows 必看）

- 读文本一律 `Get-Content -Raw -Encoding UTF8 <路径>`，否则中文会乱码。
- 改 JSON 优先用你的文件编辑工具；用 PowerShell 时必须 `ConvertTo-Json -Depth 10`，再 `Set-Content -Encoding UTF8`。
- 清单很大，不要整个打印：按 id 查一项，例如 `(Get-Content -Raw -Encoding UTF8 state\assets.json | ConvertFrom-Json).items | ? id -eq 'part_sac'`。
- Windows 上一般没有 Python，只用 PowerShell 和文件工具。

## 文件

- 清单 `state/assets.json`（第一次从本技能 `assets/assets.json` 复制）：`items` 里每项有 `n`、`id`、`file`、`cn`、`category`、`villain`、`ratio`、`bg`、`prompt`、`negative`；开头有 `total`、`anchor_batch`（定调批）、`reference_sheet`（风格参考图提示词）。
- 每轮开始先看工作区根目录有没有新的 `ART_ASSETS.json`（Claude 给的）：有就按 references/flow.md「换清单」合并。
- 工作区结构和 `progress.json` 格式：references/workspace.md。审核页和各种文字格式：references/review.md。

## 用户会说的话

Codex 不会把技能带到下一轮，所以用户每条消息都以 `$chimera-art` 开头（审核页的结果自带）。你停下时总要告诉他下一条发什么。

| 用户说（`$chimera-art` 之后） | 你做 |
|---|---|
| 开始 | 第一次：准备工作区（workspace.md），进入「选画风」。已经开始过：同"继续"。 |
| 继续 | 读 progress.json，按 flow.md「继续」接着做。 |
| 审核结果 …… | 按 review.md 应用，然后按 flow.md 做下一步。 |
| 【补图请求】…… | 按 flow.md「补图」。 |
| 进度 | 已通过 x/总数、待审、待重画、跳过的、补图任务，和下一步。 |
| 打包 | 按 flow.md「打包」立刻打包已通过的图。 |
| 重画 文件名：意见 | 记为重画（已通过的也行），放进下一批。 |
| 换风格 | 先问他确认（已通过的图都要重做），再按 flow.md「换风格」。 |

## 阶段（细节都在 references/flow.md）

1. **选画风**：3 张风格参考图，用户在审核页选一个。
2. **定调批**：清单 `anchor_batch` 的 7 项。全部通过后自动打包一次并**停下**，让用户可以先给 Claude 看效果，等他发"继续"再批量生产。
3. **批量**：每批约 8 项，每项出候选、自检、预选，然后出审核页，**等用户**贴回审核结果。
4. **打包**：`outbox/art_pack.zip`。
5. **补图**：只做补图请求里的图，审核通过后出 `outbox/fix_NN.zip`。

出图规则：references/prompting.md。自检：references/selfcheck.md。出错：references/troubleshooting.md。

## 汇报

每次停下时用三五行中文说清：做了什么、审核页路径（如 `D:\chimera_art\review.html`）、他下一步发什么（如 `$chimera-art 继续`）。额度用完时先保存，再说恢复时间和"到时点「新对话」发 `$chimera-art 继续`"。
