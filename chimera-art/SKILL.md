---
name: chimera-art
description: 为开源游戏《奇美拉纪元 Chimera Epoch》批量生产 2D 美术资产（约 88 张：角色立绘、反派、配饰部件、图标、战斗背景、卡图、界面）。只用 Codex 内置的 image_gen 出图（走 ChatGPT 订阅，不用 API key）：先让用户选一次整体画风，再分批出图、自检、预选，生成审核页让用户审，按审核结果重画，合格的图按清单文件名存进 art_pack 并打包成 zip 交给 Claude。也处理 Claude 写的「补图请求」和审核页生成的「审核结果」。Use when the user mentions 奇美拉 / chimera-art / 美术资产 / 补图请求 / 审核结果 / 选画风.
metadata:
  short-description: 奇美拉纪元美术资产生产（出图、自检、审核、打包）
---

# 奇美拉纪元 · 美术资产生产

用户不是程序员，用中文和他交流：句子短，一次只问一件事，不问技术问题，不让他装软件。
他的流程是：在这个文件夹里让你出图 → 他在审核页里审 → 全部合格后把 zip 交给 Claude（Claude 用 Godot 做游戏）→ Claude 发现问题会写一段「补图请求」，他再粘贴给你。

## 红线

- **只用内置的 `image_gen` 工具出图**（每次调用出一张）。绝不使用 imagegen 技能的 CLI 备用模式、`scripts/image_gen.py`、OpenAI API 或 `OPENAI_API_KEY`，也不要向用户要 key。工具列表里没有 `image_gen`、或者出图报错时，按 references/troubleshooting.md 处理，不要绕路。
- **所有角色都是成年人**，服装可以甜美迷人，但不裸露、不色情。被内容政策拦截时按 references/prompting.md 第 6 节改写，不争辩。
- **文件名必须和清单完全一致**（例如 `part_sac.png`）。合格的图只放进 `art_pack/`，只有用户要求重画并通过后，才覆盖 `art_pack/` 里的旧图。
- **进度写在 `state/progress.json`**，每做完一步就保存。会话随时可能中断（额度用完、用户关掉窗口），下次用户说"继续"时要能接上。
- **一个对话别出太多图**：图多了 Codex 会越来越慢、占很大硬盘。每审完两批（约 16 张），提醒用户点「新对话」，发 `$chimera-art 继续`。不要用子代理并行出图，一张一张按顺序来。

## 文件

- 清单：`state/assets.json`（第一次从本技能的 `assets/assets.json` 复制过来）。每项有 `n`（编号）、`id`、`file`、`cn`（中文名）、`priority`、`category`、`villain`、`ratio`、`gen_size`、`bg`（纯白 / 纯黑 / 画面本身）、`prompt`、`negative`。开头有 `total`、`anchor_batch`（定调批 7 项）、`reference_sheet`（风格参考图提示词）。
- 用户放进来一份新的 `ART_ASSETS.json`（Claude 给的，清单有变化）时：用它替换 `state/assets.json`，按 `id` 保留已有进度，新增的项记为待做，然后告诉用户变了哪些。
- 工作区结构、`progress.json` 的格式：references/workspace.md。

## 用户会说的话

Codex 不会把技能带到下一轮，所以用户的每条消息都应以 `$chimera-art` 开头（审核页生成的结果已经带上了）。你每次停下时都要告诉他下一条发什么，并带上这个开头。

| 用户说（`$chimera-art` 之后） | 你做 |
|---|---|
| 开始 | 第一次：准备工作区（references/workspace.md），然后进入「选画风」。已经开始过：同"继续"。 |
| 继续 | 读 `state/progress.json`，从中断的地方接着做（还有审核页没审完，就提醒他先审）。 |
| 审核结果 …… | 按 references/review.md 应用审核结果，然后接着做下一批。 |
| 【补图请求】…… | 进入「补图」（下面第 5 步）。 |
| 进度 | 显示：已通过 x/总数、待审、待重画、跳过的，和下一步要做什么。 |
| 打包 | 立刻按第 4 步打包已通过的图（没做完也可以）。 |
| 重画 文件名：意见 | 把这项记为重画（已通过的也行），意见放进下一批。 |
| 换风格 / 重新选画风 | 回到「选画风」，选完后已通过的图都要重做（先问他确认）。 |

## 流程

### 1. 选画风（只做一次）
用清单的 `reference_sheet` 出 3 张风格参考图（六个种族角色同框），每张在提示词后面加一个方向（references/prompting.md 第 3 节的 A / B / C）。生成审核页（style 模式，references/review.md），打开它，让用户选一个、可以写一句意见。
把选中的方向和意见（译成英文）记进 `progress.json` 的 `style`；选中的图复制成 `style/style_ref.png`。这句风格方向以后加在**每一张**图的提示词里。

### 2. 定调批
按 `anchor_batch` 做 7 项（我方角色、反派、部件、图标、背景各有代表），出图规则和后面一样。7 项都通过后，告诉用户"画风定下来了"，进入批量生产。定调批没通过就按意见重画，必要时回到第 1 步。

### 3. 批量生产
按编号顺序，每批取 8 项左右还没通过的（待重画的优先放进下一批）。每一项：
1. 按 references/prompting.md 拼提示词（构图写在最前面），按第 4 节带上参考图。
2. 出候选：角色立绘（`body_`，含反派）、Boss、标题图出 **2 张**，其他出 **1 张**。
3. 出完马上把图复制到 `candidates/`（路径见 references/workspace.md），看工具结果里的图，按 references/selfcheck.md 自检。不合格就针对问题改一句再出，同一项最多多出 2 张。
4. 选出最好的一张当首选（其他留作候选）。
一批做完后生成审核页（items 模式），打开它，告诉用户："第 N 批好了，请在审核页里审，审完点「生成审核结果」，复制粘贴给我。"然后**等用户**，不要自己往下做。

用户贴回审核结果后：通过的复制进 `art_pack/<file>`，要重画的记下意见放进下一批。每通过约 20 张，提醒用户可以随时说"打包"先给 Claude 看看。

### 4. 打包
`art_pack/` 里要有 `credits.txt`（UTF-8，一行：`Codex 内置图像生成（ChatGPT 订阅）`）。只把 `art_pack/` 里的图和 credits.txt 压进 `outbox/art_pack.zip`（平铺，不要子文件夹；命令见 references/workspace.md）。
告诉用户 zip 在哪，并说："把它放进游戏文件夹，交给 Claude 就行。"全部 88 项都通过时，说"美术全部完成"。

### 5. 补图（Claude 的补图请求）
补图请求里每行有编号【n】、文件名和原因（"缺失"或"重做：原因"）。按**文件名**在清单里找到这一项：
- "重做"：把原因译成英文加到提示词末尾，重新出图（不要参考旧图里有问题的地方）。
- "缺失"：正常出图。
- 写着"风格已更换"：先确认 `state/assets.json` 已经换成新的（没有就请用户把 Claude 给的 ART_ASSETS.json 放进这个文件夹），然后回到第 1 步重新选画风、第 2 步定调，再做列出的项。
照常自检、生成审核页让用户审。全部通过后：新图覆盖进 `art_pack/`，**只把这次补的图**（加 credits.txt）压进 `outbox/fix_01.zip`（编号递增），告诉用户把它交给 Claude。

## 汇报

每次停下来等用户时，用三五行中文说清：做了什么、审核页在哪（`review.html`，已经帮他打开）、他下一步要发什么（例如 `$chimera-art 继续`）。出图额度用完时，先保存进度，再说"额度用完了，过几个小时回来，点「新对话」发 `$chimera-art 继续` 就行"。
