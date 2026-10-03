# Godot 4.7 工作流（安装 · 连接 · 命令 · GDScript 规则 · 测试 · 截图 · 导出 · 排错）

## 目录
1. 安装 Godot
2. Claude 如何"连接" Godot：CLI（默认）与可选的 MCP
3. 命令速查
4. GDScript 4.7 规则与常见坑
5. 场景、UI 与输入的构建方式
6. 测试
7. 截图与画面验证
8. 性能预算
9. 导出与发布构建
10. 排错表

---

## 1. 安装 Godot（当前稳定版 4.7.x；4.8 仍在开发中，不要用）

| 系统 | 步骤 |
|---|---|
| Windows | 从 https://godotengine.org/download 下载 "Godot Engine – Standard"（不要选 .NET 版），解压到 `C:\Godot\`，里面同时有 `Godot_v4.7.x-stable_win64.exe` 和 `..._console.exe`。**命令行一律用 `_console.exe`。** 然后设置环境变量 `GODOT_PATH=C:\Godot\Godot_v4.7.2-stable_win64_console.exe`。Claude Code 在 Windows 上通过 Git Bash 运行脚本，路径写作 `/c/Godot/...` |
| macOS | `brew install --cask godot`，或者下载 .dmg 拖进"应用程序"。可执行文件在 `/Applications/Godot.app/Contents/MacOS/Godot` |
| Linux | 下载 `Godot_v4.7.x-stable_linux.x86_64.zip`，解压后 `chmod +x`，放进 `~/.local/bin/godot` 或者设置 `GODOT_PATH` |

验证安装：`bash SKILL_DIR/scripts/find_godot.sh`，能打印出路径即可。`"$GODOT" --version` 应该输出 `4.7.x.stable...`。

导出发布包还需要**导出模板**：在编辑器里打开"编辑器 → 管理导出模板 → 下载"，或者下载 `.tpz` 文件后手动安装。

## 2. Claude 如何"连接" Godot

**A. 命令行（默认，最稳，验收以它为准）**：Claude Code 直接运行 Godot 可执行文件，做无头导入、测试、平衡模拟、冒烟运行和截图，然后读取输出和 PNG。不需要任何插件。

**B. 可选：MCP 服务器**，用来让 Claude 操作编辑器、读取运行时的调试输出。

- **Coding-Solo/godot-mcp**（社区里使用最多，不需要编辑器插件）：
  ```bash
  claude mcp add godot -e GODOT_PATH="/path/to/godot" -- npx @coding-solo/godot-mcp
  ```
  它能启动编辑器、以调试模式运行项目、获取控制台输出、创建场景和节点、管理 UID。
- **hi-godot/godot-ai**（MIT，要求 4.7+，以编辑器插件形式工作）：从 Releases 下载，放进 `项目/addons/godot_ai/`，在"项目设置 → 插件"里启用，然后在它的 Dock 面板点 Configure，复制它生成的 `claude mcp add ...` 命令执行。它可以直接编辑场景节点、脚本、信号、UI、材质、动画、粒子。
- Claude Desktop 用户：把同样的 server 写进 `claude_desktop_config.json` 的 `mcpServers` 字段：
  ```json
  {"mcpServers": {"godot": {"command": "npx", "args": ["@coding-solo/godot-mcp"], "env": {"GODOT_PATH": "/path/to/godot"}}}}
  ```

**用法约定**：MCP 只用来辅助观察，比如看运行时报错、在编辑器里定位节点。**代码和数据仍然以文件为准**，用 Edit/Write 修改。每次改完都要跑 `godot_check.sh`。不要让 MCP 生成的大段 `.tscn` 取代代码构建的 UI。

## 3. 命令速查（在项目根目录执行，`$GODOT` 来自 find_godot.sh）

```bash
"$GODOT" --headless --path . --import                                    # 新克隆或新增 class_name 后执行
"$GODOT" --headless --path . --script res://tools/check_scripts.gd       # 检查所有 .gd 能否编译
"$GODOT" --headless --path . --script res://tests/run_tests.gd           # 跑全部测试
"$GODOT" --headless --path . --script res://tests/run_tests.gd -- fusion # 只跑文件名包含 fusion 的测试
"$GODOT" --headless --path . --quit-after 120                            # 主场景冒烟运行，看有没有 ERROR
"$GODOT" --headless --path . --script res://tools/balance_sim.gd -- n=400 tier=2 seed=1 out=reports/b.csv
"$GODOT" --path . --audio-driver Dummy --resolution 1600x900 --script res://tools/screenshot.gd -- res://scenes/main.tscn screenshots/x.png 90 [按键]
"$GODOT" --path . -e                                                     # 打开编辑器（给用户手动查看）
"$GODOT" --path .                                                        # 直接运行游戏
bash SKILL_DIR/scripts/godot_check.sh . [--shot screenshots/x.png] [--key R] [--balance]   # 以上检查一次全跑
```

在没有显示器的 Linux 上截图：`xvfb-run -a -s "-screen 0 1600x900x24" "$GODOT" --rendering-driver opengl3 ...`（godot_check.sh 会自动处理）。

## 4. GDScript 4.7 规则与常见坑

**语法**（Godot 3 写法会直接报错）：

| 不要写 | 改成 |
|---|---|
| `yield(x, "done")` | `await x.done` |
| `export var a = 1` / `onready var b = $B` | `@export var a := 1` / `@onready var b := $B` |
| `connect("pressed", self, "_on")` | `pressed.connect(_on)` |
| `scene.instance()` | `scene.instantiate()` |
| `rand_range(a, b)` | `randf_range(a, b)`（sim 里改用 rng 实例） |
| `KinematicBody2D` / `Tween.new()` | `CharacterBody2D` / `create_tween()` |
| `get_tree().change_scene("...")` | `get_tree().change_scene_to_file("...")` |
| `str2var` / `to_json` | `str_to_var` / `JSON.stringify` |

**类型推断**（本项目最常见的报错来源）：
- `var x := dict["k"]`、`var c := some_dict.base`、`for u in untyped_array:` 之后再写 `var p := u.method()`，都会报 **Parse Error: Cannot infer the type**。要写显式类型：`var x: int = dict.get("k", 0)`、`for u: UnitState in arr:`。
- 类型化数组 `Array[UnitState]` 用 `.filter()` 或 `.duplicate()` 之后得到的是普通数组，要标注循环变量的类型。
- JSON 里的数字一律解析成 float，用作计数、下标或比较时要 `int()`。
- 字典可以用点号访问（`d.key`），但键不存在时会直接报错。可能缺失的键用 `d.get("key", 默认值)`。

**项目机制**：
- 有 `class_name` 的脚本必须在 `--import` 之后才会被全局识别。新克隆或新增类之后先导入。
- 用 `--script` 跑一个 `extends SceneTree` 的脚本时：在 `_initialize()` 里 autoload 还不存在，从第一帧 `_process` 开始才有；在 `_initialize()` 里 add_child 的场景，它的 `_ready` 有可能拿不到 autoload，所以场景应该在第一帧再加进来。
- autoload 的名字不能和 class_name 重名（本项目用 `Data` 包装 GameData，`Rng` 包装 RngStreams）。
- 在内部类（`class _Body: extends Node2D`）里，用 `owner_view.x` 访问外部实例，不要依赖 `get_parent()` 的类型。
- 静态函数里不能访问成员变量。sim 的辅助函数一律写成 static，把状态作为参数传进去。
- Logger（4.5+）：`OS.add_logger(MyLogger.new())` 能截获脚本运行时错误，测试运行器就是靠它让崩溃的测试变红。
- Windows 上普通 exe 不会输出到终端，要用 `_console.exe`。

**风格**：
- 文件名用 snake_case，类名用 PascalCase，私有成员加 `_` 前缀，全部加类型标注。
- 一个文件只做一件事，超过约 400 行就拆。
- 信号命名用过去式（`unit_died`）。调用链"向下调用，向上发信号"。

## 5. 场景、UI 与输入的构建方式

- **场景文件保持最小**：`.tscn` 只放根节点和脚本，其余节点在 `_ready()` 里用代码创建。这样 AI 改起来可靠，diff 也清楚。必须在编辑器里可视化调整的东西（比如关卡背景摆放），才用 .tscn，而且让编辑器或 MCP 来保存，**不要手写 `uid="uid://..."`**。
- **UI**：
  - 布局用 Container（VBoxContainer、HBoxContainer、GridContainer、MarginContainer）加锚点预设（`set_anchors_preset(Control.PRESET_FULL_RECT)`）。
  - 主题统一放在 `ui/theme.tres`，或者用代码创建 Theme；需要打包 CJK 字体（见 visual-system §11）。
  - 按钮用 `button.pressed.connect(func(): ...)` 绑定。
- **场景切换**：做一个 `Game` autoload 持有 RunState，用 `get_tree().change_scene_to_file("res://scenes/battle.tscn")` 切换；参数通过 `Game` 传递，不要放进全局变量。
- **输入**：在 autoload 的 `_ready` 里调用 `InputMap.add_action("end_turn")` 和 `InputMap.action_add_event(...)` 注册。不要手改 `project.godot` 里 `[input]` 段的序列化对象。
- **表现层播放 sim 事件**：
  ```gdscript
  for ev in sim.events:
      await _play(ev)  # 每个事件返回一个 tween.finished 或计时器
  ```
  要支持倍速：`Engine.time_scale` 只影响表现，或者用自己的 speed 系数。

## 6. 测试

- 测试放在 `tests/test_<模块>.gd`，`extends TestCase`。所有 `test_*` 方法都会被执行，`before_all()` 会自动加载 `db`。
- 断言：`check(条件, 信息)` 和 `check_eq(实际值, 期望值, 信息)`。一个测试如果一个断言都没执行，或者执行时出现运行时错误，都会算失败。
- 需要随机数的测试用 `rng(种子)` 拿一个确定的生成器。测试里**不要依赖** autoload。
- 每个 sim 规则至少覆盖：正常路径、边界（满格、0 层、死亡链）、确定性（同一个种子得到同一份事件日志）。
- 表现层很难做单元测试，靠冒烟运行（不能出 ERROR）和截图检查来验证。
- 想用 GUT 或 gdUnit4 可以自行加进 `addons/`，但内置的运行器必须一直保持可用，因为 CI 依赖它。

## 7. 截图与画面验证

- `tools/screenshot.gd` 的参数依次是：场景、输出路径、等待帧数（默认 90），以及一个可选的按键（截图前模拟按下）。
- 需要验证某个特定的 UI 状态时，给场景加一个调试入口（按键，或者读取 `OS.get_cmdline_user_args()` 的参数），让截图工具能直接进入那个状态。
- 截完图**必须用 Read 打开 PNG 自己看**，按 visual-system §12 的清单逐项检查。
- 截图的命名规则是 `screenshots/<里程碑>_<功能>.png`。它们不进 git（已 gitignore），但在 PROGRESS.md 里记录路径。

## 8. 性能预算

- 目标是低配笔记本上 60 FPS，Web 导出能流畅运行。
- 一场战斗最多 12 个单位外加若干召唤物，每帧重绘（`queue_redraw`）没有问题。
- 平衡模拟：400 场应该在几秒内跑完。如果明显变慢，检查是否在 sim 里创建了 Node，或者在循环里重复调用 `validate()`。
- 粒子数量上：每个单位最多 1 个特效发射器，Compatibility 渲染器优先用 CPUParticles2D。

## 9. 导出与发布构建（M8）

- 在编辑器里创建 `export_presets.cfg`：Windows Desktop、Linux、macOS、Web。这个文件要提交到仓库，但其中的签名凭据等敏感内容不能提交。
- 命令行导出：`"$GODOT" --headless --path . --export-release "Windows Desktop" build/windows/ChimeraEpoch.exe`
- Web 导出：用 Compatibility 渲染器，并关闭 "Thread Support"，这样才能部署到 GitHub Pages 或 itch.io，不需要 COOP/COEP 响应头。
- 可以在 CI 里加一个导出任务，用缓存的导出模板，把构建产物上传为 artifact。**发布到 Release 或 itch.io 之前先问用户。**

## 10. 排错表

| 现象 | 原因 / 解决 |
|---|---|
| `Cannot infer the type of "x"` | 对 Variant 用了 `:=`，改成显式类型 |
| `Identifier "Foo" not declared` / `Could not find type` | 没有 `--import`，或者 class_name 拼错 |
| `Nonexistent function 'new' in base 'GDScript'` | 被依赖的脚本编译失败，往上翻找第一个 Parse Error |
| 测试里拿不到 autoload | 测试里不要用 autoload，改用 `GameData.load_default()` |
| Windows 终端没有输出 | 换成 `_console.exe` |
| 截图全黑或者截不出来 | 用了 `--headless`（截图必须真渲染），或者 Linux 上没有 DISPLAY（用 xvfb-run，并加 `--rendering-driver opengl3`） |
| `ERR_CANT_OPEN` 音频报错 | 加 `--audio-driver Dummy` |
| 中文显示成方块 | 系统里没有中文字体，打包一个 OFL 授权的 CJK 字体 |
| 同一个种子两次结果不同 | sim 里用了全局随机（randi、shuffle、pick_random）、用了 Time 或 delta 之类和时间相关的值，或者 sort_custom 的比较函数不是严格的"小于"（相同的值必须用 uid 之类的字段再比一次） |
| `Invalid polygon data, triangulation failed` | 传给 draw_colored_polygon 的多边形自相交或退化（点重复、面积为 0） |
