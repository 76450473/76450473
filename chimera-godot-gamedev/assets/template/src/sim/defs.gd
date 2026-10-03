class_name Defs
extends RefCounted
## Central vocabulary + tuning constants for genes, combat and fusion.
## Every string id used in data/*.json must appear here; tests/test_data.gd enforces it.
## Change numbers here (not scattered in code) and re-run tools/balance_sim.gd.

const SLOTS := ["head", "skin", "limb", "core", "back"]
const RARITIES := ["common", "rare", "epic", "legendary"]

const TRIGGERS := ["passive", "on_round_start", "on_attack", "on_hit", "on_death",
	"on_kill", "on_ally_death", "on_round_end"]
const ACTIONS := ["damage", "apply_status", "heal", "gain_armor", "buff_atk", "summon"]
const CARD_ONLY_ACTIONS := ["analyze"]
const TARGETS := ["self", "other", "lane_enemy", "enemy_area", "ally_area", "adjacent_allies",
	"all_enemies", "all_allies", "random_enemy", "lowest_hp_ally"]
const CARD_TARGETS := ["chosen_enemy", "chosen_ally", "all_enemies", "all_allies", "none"]
const STATUSES := ["poison", "regen", "infect", "stun", "vulnerable"]
const BENEFICIAL_STATUSES := ["regen"]
const BENEFICIAL_ACTIONS := ["heal", "gain_armor", "buff_atk", "summon"]
const ENEMY_SIDE_TARGETS := ["other", "lane_enemy", "enemy_area", "all_enemies", "random_enemy"]
const ALLY_SIDE_TARGETS := ["self", "ally_area", "adjacent_allies", "all_allies", "lowest_hp_ally"]
## Used by fusion to keep any form×essence combination legal (help allies, hurt enemies).
const MIRROR_TARGET := {
	"other": "self", "lane_enemy": "self", "enemy_area": "ally_area", "all_enemies": "all_allies",
	"random_enemy": "lowest_hp_ally", "self": "lane_enemy", "ally_area": "enemy_area",
	"adjacent_allies": "enemy_area", "all_allies": "all_enemies", "lowest_hp_ally": "random_enemy",
}

const PART_KINDS := ["none", "sash", "plating", "satchel", "spear", "banner", "eye_compound",
	"shell_plate", "sac", "spray_nozzle", "egg_sac", "volatile_sac", "mandible", "spore_cap",
	"tendril", "mycelium_web", "bloom", "fang", "fur_mane", "claw", "crest", "crystal_cluster",
	"prism", "core_gem", "halo", "ether_veil", "soul_claw"]
const LAYERS := ["", "chitin", "mycelium", "crystal", "fur", "ether", "rot"]
const SHAPES := ["symmetric", "segmented", "blob", "muscle", "faceted", "wisp"]
## Art pipeline: where a textured part is pinned (CreaturePainter.anchor_point) and which
## image point is the pivot (ArtImporter.anchor_pivot).
const ART_SOCKETS := ["eye", "eye_top", "head_top", "mouth", "halo", "torso", "back", "core", "limb"]
const ART_ANCHORS := ["center", "bottom_center", "top_center", "left_center", "right_center"]
const BODY_PLANS := ["biped", "hexapod", "cluster", "quadruped", "construct", "floater"]

# ---- Power budget (one number to compare any gene / card / enemy) ----
const ACTION_POWER := {"damage": 1.0, "heal": 0.8, "gain_armor": 0.7, "buff_atk": 2.0, "summon": 4.0}
const STATUS_POWER := {"poison": 0.9, "regen": 0.7, "infect": 1.1, "stun": 3.0, "vulnerable": 1.2}
const TARGET_MULT := {"self": 1.0, "other": 1.0, "lane_enemy": 1.0, "enemy_area": 2.0,
	"ally_area": 1.8, "adjacent_allies": 1.5, "all_enemies": 3.2, "all_allies": 2.8,
	"random_enemy": 0.9, "lowest_hp_ally": 1.1}
const TRIGGER_FREQ := {"passive": 0.0, "on_round_start": 1.0, "on_attack": 1.0, "on_hit": 0.8,
	"on_death": 0.6, "on_kill": 0.5, "on_ally_death": 0.6, "on_round_end": 1.0}
const STAT_POWER := {"hp": 0.25, "atk": 1.0, "spd": 0.4, "armor": 0.3}
## Validator range per rarity (gene power). Out of range = data bug or deliberate outlier to justify.
const RARITY_POWER := {"common": [0.8, 4.5], "rare": [2.0, 7.0], "epic": [3.5, 11.0], "legendary": [6.0, 16.0]}

# ---- Combat ----
const LANES := 3
const ROWS := 2  # row 0 = front, row 1 = back
const MAX_ROUNDS := 30
const EROSION_START := 15  # from this round, every unit loses (round - start + 1) hp at round end
const TRIGGER_DEPTH_LIMIT := 6
const TRIGGERS_PER_ROUND_CAP := 300
const VULNERABLE_MULT := 1.5
const ENERGY_PER_ROUND := 3
const ENEMY_POWER_MULT := 1.6  # enemy gene budget multiplier (compensates player tactic cards)
const ENEMY_HP_MULT := 1.25  # applied by CombatSim to side 1 units at spawn
const HAND_SIZE := 4

# ---- Genome ----
const CROSS_RACE_STABILITY_MULT := 1.5
const PURE_BLOOD_HP_MULT := 1.2
const PURE_BLOOD_MIN_GENES := 2
const VISUAL_BASE_WEIGHT := 12.0
const VISUAL_MAX_PROMINENT := 3

# ---- Text ----
const STATUS_NAME := {"poison": "毒", "regen": "再生", "infect": "感染", "stun": "眩晕", "vulnerable": "易伤"}
const TRIGGER_TEXT := {"passive": "", "on_round_start": "回合开始时", "on_attack": "攻击后",
	"on_hit": "受到攻击时", "on_death": "死亡时", "on_kill": "击杀时", "on_ally_death": "友方死亡时",
	"on_round_end": "回合结束时"}
const TARGET_TEXT := {"self": "自身", "other": "对方", "lane_enemy": "同列最前的敌人",
	"enemy_area": "目标及其相邻敌人", "ally_area": "自身及相邻友军", "adjacent_allies": "相邻友军",
	"all_enemies": "所有敌人", "all_allies": "所有友军", "random_enemy": "随机敌人",
	"lowest_hp_ally": "生命最低的友军"}
const ELEMENT_COLOR := {"poison": "#7bd23c", "infect": "#c9d88a", "regen": "#e0524a",
	"stun": "#f2d24b", "vulnerable": "#b06ae0", "damage": "#f08a3c", "gain_armor": "#86b1d6",
	"heal": "#6ad2a8", "buff_atk": "#e8603e", "summon": "#e3c08f"}
