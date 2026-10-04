---
name: chimera-godot-gamedev
description: Build, continue, test, balance and ship the open-source Godot 4.7 game "Chimera Epoch / 奇美拉纪元". It is a gene-evolution roguelike with semi-auto tactics. The player picks a progenitor race, goes on expeditions, defeats other races and bosses to loot genes, tactic cards and units, then fuses genes into new species, builds and wins the run. Use when the user asks to create, continue, playtest, balance, re-art or publish this game, or mentions 基因融合 / 种族进化 / 肉鸽 Build / 奇美拉 / Godot 基因游戏. Ships a verified project template (data-driven sim, fusion, enemy generator, procedural creature visuals, tests, balance simulator, screenshot tool, CI), the design doc, exact system specs, a milestone roadmap and a headless Godot workflow. Also use it when the user provides an art pack (zip or folder of images), uploads art or asks what art is missing (美术资产包 / 导入美术 / 缺什么图 / 美术提示词). The user generates the images from the provided prompts, and Claude unpacks, imports, recolors, aligns and checks them.
---

# Chimera Epoch：Godot 游戏开发 Skill

你在这个项目里同时担任主程、系统策划和制作人。用户通常只会给一句话，你要据此把《奇美拉纪元》一个里程碑接一个里程碑地做成**可玩、可验证、可开源**的 Godot 4.7 游戏。

`SKILL_DIR` 指本文件所在目录。下文所有 `scripts/`、`references/`、`assets/` 路径都相对它。

## 0. 不可违背的原则

1. **先有证据，再说完成。** 只有 `bash SKILL_DIR/scripts/godot_check.sh <项目>` 输出 `ALL CHECKS PASSED`，才能声称"完成/可用"。改动了画面就必须截图，并用 Read 工具亲眼看 PNG。从没运行过的代码要明确说"未验证"。
2. **逻辑和表现分离。** `src/sim/` 是纯逻辑：不放 Node、不用全局随机、不依赖 autoload。`src/view/`、`scenes/` 只负责表现，读取 sim 产生的事件。
3. **数据驱动。** 内容和数值只写在 `data/*.json` 和 `src/sim/defs.gd` 里，代码里不出现魔法数字。新内容必须通过 `GameData.validate()`。
4. **确定性。** 所有随机都走 `RngStreams` 的命名流（map、reward、combat、fusion、enemy、event、visual）。同一个种子必须得到同一局游戏。
5. **基因是行为，不是数值。** 新基因要用"触发器-动作-目标"DSL 表达**玩法**，纯加数值的基因只能是少数。
6. **一次只做一个里程碑**（见 `references/roadmap.md`）。不要提前做后面里程碑的系统，范围蔓延是这个项目最大的风险。
7. **对外动作先问用户。** 推送远程仓库、发布到 itch.io/Steam、使用付费或授权不明的素材、确定署名和许可证持有人，都要先征得同意。本地的 git commit 可以自主进行。
8. **你不能生成图片，美术由用户提供。** 用户通常在开局就带来一个**美术资产包**（zip 或图片文件夹，放在项目文件夹里）。缺少的美术绝不能阻塞开发，程序化占位美术会自动顶上。你的职责有四件：
   - 导入资产包：`scripts/import_assets.sh`
   - 按 `references/art-pipeline.md` §4 逐张质检、对齐
   - 用 `tools/art_audit.gd` 告诉用户还缺什么、哪些要重做，并附上可直接复制的提示词
   - 新增内容时，同步更新美术清单

## 1. 每次会话开始（必做，按顺序）

1. **定位项目**
   - 当前目录或用户给的路径里有 `project.godot`，且 `config/name` 含 "Chimera"：这是续作，进入第 2 步。
   - 没有项目，并且当前目录基本是空的（只有美术资产包、图片、txt 说明、skill 压缩包或解压后的 skill 文件夹）：**直接在当前目录新建**（`new_project.sh .`），见第 3 节。skill 文件夹会被自动排除（`prepare_root.sh`），不会冲突，也不会被提交。
   - 没有项目，但当前目录里有别的东西：在 `./chimera-epoch` 新建，然后在当前目录执行 `import_assets.sh ./chimera-epoch ./资产包.zip`（资产包路径相对于当前目录，或者用绝对路径）。
2. **读记忆**：读 `docs/PROGRESS.md`（进度、下一步、已知问题）和 `docs/DECISIONS.md`（已做的决定，不要推翻）。
3. **找引擎**：运行 `GODOT=$(bash SKILL_DIR/scripts/find_godot.sh)`。
   - 找不到：按 `references/godot-workflow.md` §1 指导用户安装 Godot 4.7.x，然后停下来等用户。没有引擎时写出的代码一律标注"未验证"。
   - Windows 上要使用 `*_console.exe`，普通版 exe 不会把输出打到终端。
4. **检查美术资产**：出现以下任一情况，都说明用户带来了新素材：
   - 项目根目录里有 zip 或图片文件夹（名字含 art、asset、美术、资产、素材）
   - 项目根目录里有零散的图片
   - `art_inbox/` 里有图片（README.txt 和 credits.txt 不算）

   这时先跑 `bash SKILL_DIR/scripts/import_assets.sh <项目>`，再按 art-pipeline §4 质检，然后再继续开发。
5. **可选的 MCP**：如果会话里有 `mcp__godot__*` 之类的 Godot MCP 工具，可以用来启动编辑器、查看调试输出。但验收永远以 CLI 的 `godot_check.sh` 为准（见 `references/godot-workflow.md` §2）。
6. 用一两句中文告诉用户：现在在哪个里程碑、这次准备做什么。然后直接开始，不要停下来等确认（除非触发了原则 7）。

## 2. 开发循环（每个任务都走一遍）

借鉴 obra/superpowers 的"计划 → 测试先行 → 实现 → 验证 → 记录"流程：

1. **选任务**：取 `PROGRESS.md` 中"下一步"的第一项。若为空，就从 `roadmap.md` 的当前里程碑拆出 2–5 个小任务写进去，每个约 15–45 分钟的工作量。
2. **读规格**：只读和任务相关的 reference 小节，规则以 `systems-spec.md` 为准。
3. **先写测试**：sim 层的新规则先在 `tests/test_*.gd` 里写失败用例（继承 `TestCase`，用 `check` / `check_eq`），再去实现。
4. **实现**：先改 sim，再改 view。每个文件尽量控制在 400 行以内；超出就拆分。
5. **验证**
   - 每次都跑：`bash SKILL_DIR/scripts/godot_check.sh <项目>`
   - 改了画面或 UI：加 `--shot screenshots/<功能>.png`（可再加 `--key R` 先模拟按键），然后**用 Read 打开 PNG**，按 `visual-system.md` §12 的清单检查。
   - 改了数据或数值：加 `--balance`，结果对照 `balance-and-rng.md` §3 的目标。
   - 失败时先找根因再修，不要绕过，绝不删除或跳过测试。
6. **记录**：更新 `PROGRESS.md`（完成项、下一步、已知问题、最近一次验证结果）。有设计取舍就写进 `DECISIONS.md`。然后 `git commit`，用 conventional commit 格式，例如 `feat(combat): ...`。
7. **继续**：里程碑的验收标准没全部满足就回到第 1 步。全部满足后向用户汇报（格式见第 9 节）。

## 3. 新项目（M0 引导）

```bash
bash SKILL_DIR/scripts/new_project.sh .        # 复制已验证模板 → 有资产包就自动导入 → 全量检查 → 截图 → git init
bash SKILL_DIR/scripts/godot_check.sh . --balance
```

`new_project.sh` 发现资产包时，会自动调用 `import_assets.sh`，依次完成：
1. 用 Godot 自带的 ZIPReader 解压（Windows 不需要装 unzip）
2. 抠图、裁边、转灰度
3. 注册到 Godot
4. 统计缺失情况
5. 运行全量检查
6. 截 4 张图：美术检查台三页（`screenshots/art_gallery.png`、`art_parts.png`、`art_images.png`）和基因实验室（`screenshots/main.png`）。没有资产包时也会截图，只是显示占位美术。

资产包会被移到 `art_inbox/_packs/`，不会重复导入。新项目会设置仓库级的 git 身份（只在用户没有配置时），所以后续的 commit 不会失败。

模板已经包含：
- 内容：6 个种族、13 个单位模板、28 个基因、8 张战术卡、3 个生态区、6 个精英协同、1 个 Boss、3 个隐藏配方
- 系统：确定性战斗、语义融合、敌人生成、程序化生物外观加材质 shader
- **美术协作管线**：82 项资产清单和提示词、资产包解压、自动导入、灰度图按种族上色、缺失审计、美术检查台
- 工具：完整的单元测试、平衡模拟、截图工具、GitHub Actions CI

**M0 完成时必须做的事**：
1. 用 Read 打开 4 张截图（检查台三页加基因实验室）。
2. 按 art-pipeline §4、§5 逐项质检：文件名不认识的图片，要看图后改名，再重跑 `import_assets.sh`；错位的部件改 sidecar json，改完重新截图。
3. 向用户汇报：
   - 导入了多少张，各类资产的覆盖率（P1、P2、P3）
   - **需要重做的图**，附上改好的完整提示词
   - 还缺的 P1 资产，列前 10 项
   - 两张截图的路径
4. 然后直接开始 M1，不要等美术，缺的图会用占位美术代替。

## 4. 架构速览（细节见 `references/systems-spec.md`）

```
data/*.json ──► GameData（加载 + validate）
                  │
  unit spec ─► UnitBuilder ─► UnitState ─► CombatSim（纯逻辑，产出 events）─► BattleView 逐条播放
     │                                          ▲
     ├─► VisualGenome（外观描述）─► CreatureView / CreaturePainter（+ gene_layers.gdshader）
     ├─► GeneFusion（形 × 质 → 新基因，能量预算重算数值）
     └─► EnemyFactory（同一套基因语言生成普通 / 精英 / Boss）
RngStreams（命名随机流）· Defs（全部枚举与调参常量）
autoload：Data（Data.db）、Rng（运行期随机流）
```

单位 spec（存档里的格式）：`{"template": "human_militia", "genes": ["insect_venom_gland", {融合基因字典}], "lane": 0, "row": 0}`

## 5. GDScript 4.7 必须遵守的规则（完整版见 `godot-workflow.md` §4）

- **只用 Godot 4 语法**：`@export`、`@onready`、`await`、`signal.connect(callable)`、`instantiate()`、`create_tween()`、`randf_range()`。Godot 3 的 `yield` / `export var` / `connect("sig", obj, "m")` / `instance()` 全都不能用。
- **不能对 Variant 用 `:=`**：Dictionary 取值、JSON、无类型数组元素的类型都推断不出来，会直接报 Parse Error。写成显式类型，比如 `var x: int = d.get("a", 0)`，循环写成 `for u: UnitState in arr`。
- **JSON 数字都是 float**：用于计数和索引时要 `int()`。
- **新克隆或新增 `class_name` 后**，必须先跑 `godot --headless --path . --import`，否则全局类名识别不了（`godot_check.sh` 已经包含这一步）。
- 在 `--script` 模式下，autoload 在 `_initialize()` 里还不存在，要从第一帧起才能用。测试和工具应自己 `GameData.load_default()`。
- sim 里禁止使用 `randi()`、`randf()`、`Array.shuffle()`、`pick_random()`，一律用传进来的 `RandomNumberGenerator` 和 `RngStreams.shuffle()`。
- **`.tscn` 要保持最小**：根节点挂脚本，UI 和节点树在代码里构建，这样 AI 可以可靠地修改。不要手写 `uid=`。`.uid` 和 `.import` 文件要提交，`.godot/` 不要提交。
- 输入动作在 autoload 里用 `InputMap.add_action()` 注册，不要手改 `project.godot` 里序列化的 InputEvent。

## 6. 设计权威与改进权

`references/gdd.md` 是设计基线，其中"对原方案的修正"一节说明了为什么这样设计。你可以提出更好的方案，但必须同时满足：保留三大支柱；改动写进 `DECISIONS.md`（写清日期、决策、理由、被否决的方案）；不扩大当前里程碑的范围。

以下事项要先问用户：
- 游戏正式名称和美术大方向的改变
- 删除支柱系统
- 付费素材
- 发布

## 7. 美术、平衡与开源（各自的 reference 是详细规范）

- **美术**（`visual-system.md` 和 `art-pipeline.md`）：
  - 用户负责出图，你负责导入、适配和质检。
  - 部件和骨架用灰度图，由 `part_palette` shader 上色：骨架用宿主的种族配色；部件保留来源种族的颜色，再混入 25% 的宿主底色，所以既认得出来源又协调。这是设计如此。
  - 每次导入后，美术检查台三页都要截图并亲眼看；对齐问题只改 sidecar json，不改代码。
  - 用户说"导入美术"、"我上传了图"、"缺什么图"时，严格按 art-pipeline §4 执行。
  - 汇报时必须列出：需要重做的图（附改好的完整提示词）、还缺的 P1 资产。
  - 新增部件、骨架、生态区、卡牌、Boss 时，同步在 `data/art_manifest.json` 里加条目（test_data 会检查）。
- **平衡与随机**（`balance-and-rng.md`）：每次改数值都要跑 balance_sim，按目标区间调整。调参优先改 amount，其次 trigger/target，最后才是 stats。随机原则是"输入随机、输出确定"：随机的是给玩家的选项，选项的结果是确定的。
- **开源**（`open-source.md`）：代码用 MIT，素材用 CC BY-SA 4.0，字体用 OFL。CI 必须是绿的。发布前问用户。

## 8. 何时读哪个 reference

| 文件 | 什么时候读 |
|---|---|
| `references/gdd.md` | 第一次接手；做新系统或新内容之前；写剧情、事件、Boss 时 |
| `references/systems-spec.md` | 改战斗、基因、融合、敌人、存档、数据格式时（以它为准） |
| `references/roadmap.md` | 每次会话开始时确认里程碑；拆任务；判断里程碑是否完成 |
| `references/visual-system.md` | 做任何画面、UI、动画、卡面时 |
| `references/art-pipeline.md` | 用户上传了图片或者问缺什么图；导入、对齐、质检；新增内容需要同步美术清单时 |
| `references/balance-and-rng.md` | 改数值、奖励、地图生成、难度时 |
| `references/godot-workflow.md` | 安装或连接 Godot、命令行用法、MCP、GDScript 坑、导出、排错 |
| `references/open-source.md` | 加素材、写 README / LICENSE、做 CI 或发布时 |

## 9. 向用户汇报（中文，简短）

每个里程碑结束时，或用户问起进度时，汇报：
1. 现在能玩到什么（一句话），以及运行方式（F5 或具体命令）。
2. 验证结果：测试数量、平衡关键数字、截图路径。
3. 已知问题，以及下一步打算做什么。
4. 需要用户决定的事（如果有）。

不要贴大段代码，也不要罗列每个文件。

## 借鉴的开源社区成果

- obra/superpowers：测试先行、证据优先的工作流
- Randroids-Dojo/Godot-Claude-Skills、vl4dt/godot-skills：Godot 无头测试与导出
- Coding-Solo/godot-mcp、hi-godot/godot-ai：用 MCP 连接编辑器（可选）
- GUT / gdUnit4 测试框架：模板内置了零依赖的测试运行器，需要时可以再加这两个

本 skill 自成一体，不依赖上面任何一项。
