# 系统规格（与模板代码一一对应，改规则时同步改这里和测试）

## 目录
1. 数据文件与字段
2. 效果 DSL
3. 能量（power）模型
4. 基因组：插槽、稳定度、纯血、过载、突变
5. 融合算法
6. 战斗模拟 CombatSim
7. 敌人生成 EnemyFactory
8. 随机流 RngStreams
9. 局内存档 RunState（M2 实现）
10. 局外存档 Lineage（M6 实现）
11. 扩展清单（加基因 / 状态 / 触发器 / 种族 / Boss……）
12. 事件日志格式（战斗表现层的输入）

---

## 1. 数据文件与字段（`data/`）

所有文件的顶层都是对象，`_doc` 字段是给人看的注释。id 全局唯一，统一用小写下划线命名。

| 文件 | 顶层键 | 主要字段 |
|---|---|---|
| races.json | races[] | id, name, adj（命名用的单字）, shape, body_plan, layer, palette{base,dark,accent}, traits{capacity_bonus, cross_race_mult}, playable, theme |
| units.json | units[] | id, name, race, role（物种名词根）, hp, atk, spd, armor, slots[], capacity, innate[]（效果）, summon_only?, boss? |
| genes.json | genes[] | id, name, race, slot, rarity, stability, name_prefix（作为"质"时的前缀）, name_suffix（作为"形"时的后缀）, tags[], stats{hp,atk,spd,armor}, effects[], visual{part, layer} |
| cards.json | cards[] | id, name, cost, rarity, target（chosen_enemy/chosen_ally/all_enemies/all_allies/none）, tags[], effects[]（没有 trigger 的 DSL，可以用 analyze） |
| biomes.json | biomes[] | id, name, desc, rules{poison_tick_bonus, regen_tick_bonus, erosion_start, armor_cap_mult}, enemy_races[], fusion_mods[]{if_status/if_action, amount_delta} |
| enemies.json | synergies[], bosses[] | synergy{id,name,race,tags[]}; boss{id, unit, name, act, support_races[], support_budget, escorts[], dissect[3], intro} |
| fusion.json | rules, recipes[], species_names | rules{budget_ratio, same_race_stability, cross_race_stability, stat_carry, max_amount}; recipe{id,name,hint,form_tags_any[],essence_tags_any[],require_cross_race?,rarity,effects[],tags[],visual}; species_names{element_prefix{}, part_word{}} |

所有枚举都定义在 `src/sim/defs.gd`（SLOTS、TRIGGERS、ACTIONS、TARGETS、STATUSES、PART_KINDS、LAYERS、SHAPES、BODY_PLANS），由 `GameData.validate()` 负责校验。

## 2. 效果 DSL

一条效果：`{"trigger", "action", "target", "amount", "status"?, "unit"?}`

**触发器**

| trigger | 时机 | `other` 指谁 |
|---|---|---|
| passive | 不能写在 effects 里，被动效果请用 stats | — |
| on_round_start | 回合开始，按行动顺序依次触发 | null |
| on_attack | 自己普攻造成伤害之后（目标死了也会触发） | 被攻击者 |
| on_hit | 被普攻并且活下来之后 | 攻击者 |
| on_death | 自己死亡时（此时自己已经死了，但仍以原位置作为参照） | 击杀者，被毒死时为 null |
| on_kill | 自己击杀一个敌人后（自己必须还活着） | 被击杀者 |
| on_ally_death | 每有一个同侧友军死亡 | 死者（已死，不能当作目标） |
| on_round_end | 回合结束，在状态结算之前 | null |

**动作**

| action | 效果 |
|---|---|
| damage | 伤害，吃易伤加成，先扣护甲再扣生命 |
| apply_status | 加状态层数，需要 `status` |
| heal | 恢复生命，不超过上限 |
| gain_armor | 加护甲，上限为 max_hp × armor_cap_mult |
| buff_atk | 本场战斗内永久加攻击 |
| summon | 在召唤者附近的空格召唤 `unit`（模板 id），数量为 amount；棋盘满了就失败，记一条 summon_fail 并停止 |
| analyze | 仅战术卡可用，标记目标为已解析（M7 的观察系统会用到） |

**目标**

| target | 解析方式 |
|---|---|
| self | 自身（已死则为空） |
| other | 触发器带来的另一方（已死则为空） |
| lane_enemy | 同列最前方的敌人；同列没有就按列偏移 0,-1,+1,-2,+2 的顺序找 |
| enemy_area | 参照敌人（other 是敌人就用它，否则用 lane_enemy）以及与它相邻的同侧单位；参照敌人死了，它的邻居照样会被命中 |
| ally_area | 自身（若活着）以及与自己相邻的友军 |
| adjacent_allies | 与自己相邻的友军（不含自身） |
| all_enemies / all_allies | 全体存活的敌人 / 友军 |
| random_enemy | 用 combat 随机流随机选一个存活的敌人 |
| lowest_hp_ally | 生命百分比最低的友军（含自身） |

"相邻"指同一侧、曼哈顿距离为 1。

**状态**

| status | 结算方式 |
|---|---|
| poison | 回合末掉血 = 层数 + 生态加成，无视护甲和易伤，然后层数 -1 |
| regen | 回合末回血 = 层数 + 生态加成（最低为 0），然后层数 -1 |
| infect | 本身不结算。带感染的单位死亡时，每个相邻友军获得等于感染层数的毒，以及感染层数 -1 的感染（扩散逐层衰减） |
| stun | 跳过下一次行动，跳过时层数 -1 |
| vulnerable | 受到的伤害 ×1.5（向上取整），回合末层数 -1 |

## 3. 能量（power）模型

所有基因、卡牌、敌人预算都用同一种"货币"衡量：
```
effect_power = base(action 或 status) × amount × TARGET_MULT[target] × TRIGGER_FREQ[trigger]
gene_power   = Σ effect_power + Σ STAT_POWER[stat] × value
```

| 表 | 数值（以 `defs.gd` 为准） |
|---|---|
| ACTION_POWER | damage 1.0 · heal 0.8 · gain_armor 0.7 · buff_atk 2.0 · summon 4.0 |
| STATUS_POWER | poison 0.9 · regen 0.7 · infect 1.1 · stun 3.0 · vulnerable 1.2 |
| TARGET_MULT | self/other/lane_enemy 1.0 · enemy_area 2.0 · ally_area 1.8 · adjacent_allies 1.5 · all_enemies 3.2 · all_allies 2.8 · random_enemy 0.9 · lowest_hp_ally 1.1 |
| TRIGGER_FREQ | round_start/attack/round_end 1.0 · on_hit 0.8 · on_death/on_ally_death 0.6 · on_kill 0.5 |
| STAT_POWER | hp 0.25 · atk 1.0 · spd 0.4 · armor 0.3 |
| RARITY_POWER（校验区间） | common 0.8–4.5 · rare 2.0–7.0 · epic 3.5–11 · legendary 6–16 |

如果平衡模拟显示某个基因明显偏离它的 power，**先修正 power 表**（说明这一类效果被低估或高估了），再去改单个基因。

## 4. 基因组：插槽、稳定度、纯血、过载、突变（`UnitBuilder`）

- `can_attach(spec, gene)`：基因的插槽必须在模板的 `slots` 里，并且这个插槽还空着。
- `genome_info(spec)` 的计算：
  - `load = ceil(Σ stability × (跨族 ? cross_race_mult : 1))`
  - `capacity = 模板 capacity + 种族 capacity_bonus`
  - `pure = 所有基因都是本族，且基因数 ≥ 2`
  - `overload = max(0, load - capacity)`
- 纯血共鸣：max_hp ×1.2（取整）。
- 敌方单位在生成时 max_hp × `ENEMY_HP_MULT`（1.25），基因预算 × `ENEMY_POWER_MULT`（1.6），用来抵消玩家战术卡带来的优势。
- 过载时（M3 实现交互）：每多 1 点过载，突变概率 +10%（上限 90%）。突变调用 `GeneFusion.mutate(gene, rng=Rng.stream("fusion"))`，三种结果的概率为：优异 20%（能量 ×1.3）、侧向 60%、退化 20%（能量 ×0.7）。突变后的名字前加"畸变·"，并带上 `mutated` 字段。

## 5. 融合算法（`GeneFusion.fuse(form, essence, db, biome)`）

1. **兼容判断**：两个基因插槽相同，或者其中一个是 core。结果插槽取形的插槽；若形是 core，则取质的插槽。
2. **先查隐藏配方**：按顺序检查 `recipes`，满足"形带有任一 form_tags_any，且质带有任一 essence_tags_any（且满足 require_cross_race）"就命中。命中后直接用配方写好的 effects 和 name，标记 `recipe`，**跳过下面的步骤**。
3. **取主效果**：形和质各取 power 最高的那条效果。
4. 如果其中一方没有效果（纯数值基因），进入**强化模式**：保留另一方的效果，数值叠加。
5. **组合**：`{trigger: 形.trigger, target: 形.target, action: 质.action, status: 质.status, unit: 质.unit}`
6. **合法化** `_legalize`：
   - summon 的目标强制为 self。
   - on_ally_death 配 other 时改为 adjacent_allies。
   - 有益动作指向敌方目标，就按 MIRROR_TARGET 映射到对应的友方目标。
   - 有害动作指向友方目标（且质没有 sacrifice 标签），也映射到对应的敌方目标。
7. **数值**：
   - `budget = budget_ratio(0.85) × (power(形) + power(质))`
   - 结果的 stats = (形.stats + 质.stats) × stat_carry(0.5)，四舍五入，丢掉 0
   - `amount = clamp(round((budget - stats_power) / unit_power), 1, max_amount)`
8. **生态变调**：效果满足 `fusion_mods` 的条件时，`amount += amount_delta`，并记录 `biome_twist`。
9. **元数据**：
   - name = 质.name_prefix + 形.name_suffix
   - race = 质.race
   - visual.part 取形的（没有就取质的）；visual.layer 取质的
   - stability = ceil((形 + 质) × (同族 0.8 / 跨族 1.1))
   - rarity 取两者中较高的
   - tags 取并集
   - lineage = [形.id, 质.id]，`fused` = true
   - id = `fx_<形>__<质>`；配方结果的 id 为 `rx_…`
10. **预测** `predict()`：返回形的 trigger、target，质的 element，以及 slot，供界面在玩家确认前展示。

融合后的基因只存在于存档里，是完整的字典，`UnitBuilder.resolve_genes` 能同时处理 id 和字典两种形式。

## 6. 战斗模拟 CombatSim

```
var sim := CombatSim.new(db, rng, biome.rules)
sim.add_team(player_specs, 0)
sim.add_team(enemy_specs, 1)
while not sim.is_over():
    sim.begin_round()
    # 玩家或 AI 打牌：sim.play_card(card, 0, target_uid)
    sim.resolve_round()
```

- **棋盘**：LANES=3，ROWS=2。加入单位时如果目标格已被占用，就按 `_free_slot` 规则（后排优先，再按列）放到别处；没有空位则返回 null。
- **行动顺序** `_action_order()`：先按 spd 从高到低排序，相同的再用 combat 随机流的 randf 排序。每个阶段都重新计算一次，所以本回合召唤出的单位从下一个阶段开始参与。
- **普攻**：先检查眩晕（有眩晕则层数 -1 并跳过），选定 `lane_target`，记一条 attack 事件，然后 `_deal_damage(atk)`，再依次触发攻击者的 on_attack 和被攻击者（若活着）的 on_hit，最后检查胜负。
- **伤害管线** `_deal_damage`：
  1. 目标有易伤时，伤害 ×1.5，向上取整。
  2. 护甲吸收：`min(armor, dmg)`。
  3. 剩余部分扣生命。
  4. 生命 ≤ 0 时进入 `_kill`。
  - 毒和环境侵蚀走 `_lose_hp`，无视护甲和易伤。
- **死亡** `_kill`：标记死亡，然后依次处理：感染扩散 → 死者的 on_death → 击杀者（若活着且是敌方）的 on_kill → 所有存活友军的 on_ally_death。
- **保护机制**：
  - 触发深度上限 `TRIGGER_DEPTH_LIMIT = 6`，单回合触发次数上限 `TRIGGERS_PER_ROUND_CAP = 300`。超过时记一条 `trigger_cap` 事件，并把 `hit_trigger_cap` 置为 true，平衡模拟会统计这个值。
  - 环境侵蚀：从 `erosion_start`（默认 15）开始，每回合末所有单位失去 (round - start + 1) 点生命。
  - 第 30 回合直接判平局。
- **胜负**：-2 进行中，0 玩家胜，1 敌方胜，-1 平局（双方同时全灭或回合到上限）。
- **能量与卡牌**：每回合开始时 energy = 3。`play_card` 在费用不足、或指定目标的卡没有合法目标时返回 false。

## 7. 敌人生成 EnemyFactory

- `team_size = clamp(2 + tier + (精英 ? 1 : 0), 2, 6)`
- `budget = (4 + 3×tier) × (精英 ? 1.5 : 1) × power_mult`，敌人的 power_mult 默认为 1.6。生成玩家队伍时（平衡模拟）传 1.0。
- 每个单位分到的预算为 `budget / team_size`。
- 基因池 = 本族基因 + 生态区中其他敌族的基因（权重 0.3）。
- 最多尝试 12 次挑选。候选基因必须满足：能挂上、不超预算（允许 +0.75 的余量）、不导致过载。按权重加权随机选取。
- 精英会随机选一个本族的协同模板，模板里每命中一个标签，权重 ×4。
- 站位：按 (hp + 2×armor) 从高到低排序，依次填入 (1,0)、(0,0)、(2,0)、(1,1)、(0,1)、(2,1)。
- Boss：核心单位从 support_races 中随机挑一族，按 support_budget 生成辅助基因，再生成 escorts 护卫（每个预算 2.5）。

## 8. 随机流 RngStreams

- 流的名称：map、reward、combat、fusion、enemy、event、visual。每条流的种子为 `hash("%d:%s" % [run_seed, name])`。
- `fork(name)`：从某条流派生一个子生成器，用于单场战斗、单次奖励等，避免长时间占用父流。
- `save_state()` / `load_state()`：存档里保存每条流的 state。
- 每日种子：`RngStreams.seed_from_text("2026-10-03")`。
- **禁止**在 sim 中使用全局的 `randi()`、`randf()`、`shuffle()`、`pick_random()`。表现层的装饰性随机（比如待机动画相位）可以用全局随机。

## 9. 局内存档 RunState（M2 实现）

`user://saves/run.json`：
```json
{"version": 1, "seed": 123, "rng": {"run_seed":123,"states":{"map":"..."}},
 "race": "human", "act": 1, "node": "n7", "map": {"nodes": [...], "edges": [...]},
 "team": [unit spec...], "bench": [unit spec...], "genes": [gene id 或 字典...],
 "deck": ["card_strike", ...], "biomass": 40, "samples": 2, "stabilizers": 0,
 "discovered_recipes": ["rx_corpse_brood"], "seen_genes": ["insect_venom_gland"],
 "pressure": 0, "history": [{"node":"n3","type":"battle","result":"win"}]}
```

- 加载时检查 version，旧版本用 `migrate_v1_to_v2()` 这样的函数逐级升级。
- 写入时先写 `.tmp` 文件，再改名覆盖，防止写一半损坏存档。
- 每次进入节点前自动保存。

## 10. 局外存档 Lineage（M6 实现）

`user://lineage.json`：
```json
{"version": 1, "unlocked_races": [...], "unlocked_genes": [...], "gene_bank": [...],
 "bank_slots": 3, "max_pressure": 0, "discovered_recipes": [...], "endings": [...],
 "runs": [{"seed":..,"race":..,"result":..,"build":[..],"cause":..}]}
```

## 11. 扩展清单

**加一个基因**：
1. 在 `genes.json` 加一行。
2. 运行 `godot_check.sh`。`test_data` 会检查枚举和 power 区间，`test_every_gene_describes` 会检查描述文字。
3. 加 `--balance` 看它的胜率偏差。

**加一个状态**：
1. `Defs.STATUSES` / `STATUS_POWER` / `STATUS_NAME` / `ELEMENT_COLOR`（有益状态还要加进 BENEFICIAL_STATUSES）。
2. 在 `CombatSim._round_end` 或伤害管线里实现结算。
3. 写测试。
4. 加状态图标（visual-system §11）。

**加一个触发器或目标**：
1. 加进 `Defs` 的对应表、TRIGGER_FREQ / TARGET_MULT、TRIGGER_TEXT / TARGET_TEXT；新目标还要补 MIRROR_TARGET，并归入 ENEMY_SIDE / ALLY_SIDE。
2. 在 CombatSim 的 `_fire` 调用点或 `_resolve_targets` 里实现。
3. 写测试。

**加一个种族**：
1. `races.json`（shape、body_plan 可以复用已有的）+ 至少 2 个单位模板 + 6 个基因 + 1 个协同模板。
2. 如果 body_plan 是新的，要在 `CreaturePainter` 里加 body 函数和 sockets。
3. 截图检查。

**加一个 Boss**：
1. units.json 里写 boss 模板（innate 即核心机制，`boss: true`）。
2. enemies.json 里写 boss 条目（dissect 恰好 3 个）。
3. 在 `test_enemy_factory` 里加用例。
4. 在 GDD 第 2 节写上它要"教给玩家什么"。

**加一个生态区**：
1. 在 biomes.json 里写 rules（只能用已实现的键，新键要在 CombatSim 里实现并写测试）、fusion_mods、enemy_races。

**加一张卡**：
1. cards.json。卡牌的 power 参照基因 power，每 1 点费用大约值 2.5–3 点 power。

## 12. 事件日志格式（BattleView 的唯一输入）

| type | 字段 | 表现建议 |
|---|---|---|
| round_start | round | 回合横幅 |
| card | card, side, target | 卡牌飞向目标 |
| attack | src, dst | 攻击者前冲，然后回位（约 0.25 秒） |
| damage | src, dst, amount, absorbed, source（attack/effect/card/poison/erosion） | 飘字（护甲吸收的部分用灰色显示）、受击闪白 |
| status | dst, status, amount, source? | 状态图标弹出 |
| heal / armor / buff | dst, amount (+armor/stat) | 绿色、蓝色、红色飘字 |
| trigger | uid, gene, trigger | 单位头顶的基因图标闪一下，写入战斗日志 |
| death | uid, killer | 溶解或倒下，0.4 秒 |
| summon / summon_fail | uid, template, side, lane, row | 从召唤者身上弹出新单位 |
| stunned | uid | 头顶旋转星星 |
| analyze | dst | 扫描线特效，揭示基因 |
| trigger_cap | uid, trigger | 调试提示（正式版里隐藏） |
| round_end / end | round / winner, rounds, reason? | 结算界面 |

BattleView 播放方式：先用 `sim.initial_snapshot()` 摆好棋盘，再逐条消费事件。播放可以加速（1×、2×、4×）或跳过，但**表现层绝不能反过来修改 sim 的状态**。
