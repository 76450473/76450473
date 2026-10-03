# PROGRESS（AI 与人共用的进度记忆——每次会话结束前更新）

## 当前里程碑
M0 地基（模板自带，已验证）→ 下一步：M1 可玩的一场战斗

## 已完成
- [x] M0 数据驱动内容 + 校验（data/*.json, GameData.validate）
- [x] M0 确定性战斗模拟 CombatSim + 事件日志
- [x] M0 语义基因融合 GeneFusion（形×质、预算重算、隐藏配方、生态变调、突变）
- [x] M0 敌人生成 EnemyFactory（普通/精英协同/Boss 核心）
- [x] M0 VisualGenome + 程序化占位生物 + 材质层 shader
- [x] M0 测试 33 项、平衡模拟、截图工具、CI

## 进行中
（空）

## 下一步（按顺序）
1. M1：战斗表现层 battle_view —— 2×3 棋盘、播放 CombatSim 事件、手牌/能量 UI、敌人意图显示
2. M1：战后奖励三选一（基因 / 战术卡 / 资源），接入 Rng.stream("reward")

## 已知问题 / 技术债
- 平衡（tools/balance_sim，n=600）：tier3 各族敌人非胜率差约 25–30 点（目标 ≤20；虫族偏弱、兽族偏强）；tier1 胜率 79% 接近上限 → M3 首个调参任务
- 程序化占位美术：六足虫的近侧腿压在胸节上、人形像木偶 → M5 换正式部件美术时解决

## 最近一次验证
- tests: 33/33 通过 · balance 玩家胜率 tier1≈79% / tier2≈70% / tier3≈60%，平均 5.5–6.8 回合 · 截图 screenshots/main.png
