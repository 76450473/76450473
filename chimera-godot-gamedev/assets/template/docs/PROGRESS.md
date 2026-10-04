# PROGRESS（AI 与人共用的进度记忆——每次会话结束前更新）

## 当前里程碑
M0 地基（模板自带，已验证）→ 下一步：M1 可玩的一场战斗

## 已完成
- [x] M0 数据驱动内容 + 校验（data/*.json, GameData.validate）
- [x] M0 确定性战斗模拟 CombatSim + 事件日志
- [x] M0 语义基因融合 GeneFusion（形×质、预算重算、隐藏配方、生态变调、突变）
- [x] M0 敌人生成 EnemyFactory（普通/精英协同/Boss 核心）
- [x] M0 VisualGenome + 程序化占位生物 + 材质层 shader
- [x] M0 测试、平衡模拟、截图工具、CI
- [x] M0 美术协作管线：data/art_manifest.json（82 项资产规格+提示词）、tools/art_audit.gd（缺失清单 docs/ART_TODO.md）、
      tools/import_art.gd（art_inbox/ → 抠图/裁边/灰度/缩放/挂点 → art/）、ArtLibrary（有图用图，无图回退程序化）、
      part_palette shader（灰度图按种族上色+发光强调色）、scenes/art_gallery.tscn（美术检查台）

## 进行中
（空）

## 下一步（按顺序）
1. M1：战斗表现层 battle_view —— 2×3 棋盘、播放 CombatSim 事件、手牌/能量 UI、敌人意图显示
2. M1：战后奖励三选一（基因 / 战术卡 / 资源），接入 Rng.stream("reward")

## 美术资产
- 进度见 `tools/art_audit.gd` 输出（当前 P1 0/40 · P2 0/38 · P3 0/4），缺失清单与提示词在 docs/ART_TODO.md
- 用户的美术资产包（zip 或文件夹）放在项目根目录，或者图片放进 art_inbox/，执行 skill 的 scripts/import_assets.sh 后按 references/art-pipeline.md §4 质检

## 已知问题 / 技术债
- 平衡（godot_check --balance，n=400，seed=1）→ M3 首个调参任务：
  - 玩家胜率 tier1 79.2% / tier2 69.8% / tier3 60.0%（tier1 接近上限 80%）
  - 各敌族非胜率差：tier1 15 点 ✓，tier2 21 点（目标 ≤20），tier3 28 点（beast 56% 偏强、insect 28% 偏弱）
  - 偏差超过 ±15 的基因：wraith_soul_siphon 玩家方 -26.9（tier1）、crystal_lattice 敌方 +15.9（tier1）、fungal_plague_heart 玩家方 -17.1、insect_death_burst 敌方 -16.8、beast_thick_hide 敌方 +15.4（tier3）
- 程序化占位美术：六足虫的近侧腿压在胸节上、人形像木偶 → M5 换正式部件美术时解决

## 最近一次验证
- tests: 全部通过（见 godot_check 输出） · balance 玩家胜率 tier1≈79% / tier2≈70% / tier3≈60%，平均 5.5–6.8 回合 · 截图 screenshots/main.png
