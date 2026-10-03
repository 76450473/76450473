# 奇美拉纪元 Chimera Epoch（工作名）

基因进化 × 肉鸽 × 半自动战棋。选择一个始祖种族，远征、掠夺异族基因、融合出只属于你的物种，
最终击败各族的顶点物种与「终末之种」。

- 引擎：Godot 4.7（GDScript，Compatibility 渲染器，可导出 Windows / macOS / Linux / Web）
- 许可：代码 MIT；美术/音频/文本 CC BY-SA 4.0（见 LICENSE、CREDITS.md）

## 运行
用 Godot 4.7.x 打开本目录，按 F5。演示场景按键：D 演示组 · R 随机敌族 · F 随机融合 · B 重跑战斗。

## 命令行（CI 与 AI 开发同一套）
```bash
godot --headless --path . --import                                   # 新克隆后先执行一次
godot --headless --path . --script res://tools/check_scripts.gd      # 所有脚本语法检查
godot --headless --path . --script res://tests/run_tests.gd          # 单元测试
godot --headless --path . --script res://tools/balance_sim.gd -- n=400 tier=1   # 平衡报告
godot --path . --audio-driver Dummy --script res://tools/screenshot.gd -- res://scenes/main.tscn screenshots/main.png 90
godot --headless --path . --script res://tools/art_audit.gd          # 缺哪些美术 → docs/ART_TODO.md（含提示词）
godot --headless --path . --script res://tools/import_art.gd         # 导入 art_inbox/ 里的图片 → art/
```

## 美术协作
美术由人用 AI 生图工具生成：提示词在 `docs/ART_PROMPTS.md`，缺失清单在 `docs/ART_TODO.md`。
生成的图片放进 `art_inbox/`，运行导入工具即可。缺失的资产会自动用程序化占位美术代替。
美术检查台：`scenes/art_gallery.tscn`。

## 目录
```
data/        全部内容（种族/单位/基因/卡牌/生态区/敌人/融合）——改数值只改这里和 src/sim/defs.gd
src/sim/     纯逻辑（无 Node、无全局随机）：战斗、融合、敌人生成、随机流
src/view/    表现：VisualGenome（基因→外观描述）、CreaturePainter（程序化占位美术）、CreatureView
src/shaders/ 基因材质层（甲壳/菌丝/晶化/毛皮/灵体/腐化 渐进扩散）
tests/       零依赖测试（tests/run_tests.gd）
src/art/     美术管线：资产清单推导、图片导入处理、运行时查找（缺图回退）
tools/       平衡模拟、截图、脚本检查、美术审计与导入
art/         导入后的正式美术与 sidecar json（art_inbox/ 是原图收件箱，不入库）
docs/        PROGRESS.md（进度与下一步）、DECISIONS.md（设计决策记录）
```

## 参与贡献
1. 改动前读 docs/PROGRESS.md 与 docs/DECISIONS.md。
2. 新内容先写进 data/*.json，跑 tests + balance_sim；数值不在代码里写死。
3. 提交前：check_scripts、run_tests 必须全绿；提交新美术请在 CREDITS.md 登记授权。
