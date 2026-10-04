# 出图规则

## 1. 拼提示词

每一项的最终提示词 = 下面几段按顺序连起来：

1. 该项 `prompt` 全文，原样使用，不缩写、不改写（`image_gen` 会自己整理格式，你不要删内容）。
2. 风格方向：`progress.json` 里 `style.clause`，再加 `style.note_en`（用户选画风时的意见），定调后每张都加。选画风那一步用第 3 节的 A / B / C 方向。
3. 用户对这一项的修改意见（译成英文），重画时才有。
4. 角色句：画面里有人物时（风格参考图、`body_`、`boss_`、`title_`、画了角色的 `cardart_`）加
   `All characters are clearly adults, fully and tastefully clothed.`
5. 反派句：`villain` 为 true 或 `boss_` 时加
   `A menacing, imposing adult villain; do not copy the soft cute look of the heroine images.`
6. `Avoid: ` + 该项 `negative`，但删掉其中的 child、childlike、loli、shota、nudity、nsfw、nipples、lingerie、see-through clothing（这些词本身容易触发拦截，第 4 句已经说清楚了）。

不要往提示词里写游戏名、画师名、商标。

## 2. 尺寸和背景

- `image_gen` 不能设置尺寸和比例（工具只有 prompt、transparent_background、referenced_image_paths、num_last_images_to_include 四个参数），所以**在提示词最前面写构图**：
  - 2:3 → `Tall portrait image (2:3), full body vertical composition.`
  - 5:7（`card_back`、`card_frame`）→ `Tall portrait card image (5:7), flat front view, the whole card filling the frame.`
  - 1:1 → `Square image (1:1), subject centered.`
  - 16:9 → `Wide landscape image (16:9).`　4:3 → `Landscape image (4:3).`
  - 3:1（`ui_button`）→ `Very wide horizontal image; draw the button plate as a wide 3:1 strip across the middle half of the height, with the top and bottom quarters filled with the same flat color as the plate.`
- 出来的尺寸不固定（例如 1024×1536、1254×1254、1693×929），**不用缩放或裁剪**，游戏导入时会自动适配。只有方向明显错了（该竖的出成横的）才算不合格。
- `transparent_background` 一律不设（保持默认 false）：本项目要的是纯白平底，游戏导入时自己抠图。
- 背景按 `bg`：
  - 纯白（`body_`、`part_`、`boss_`、`card_frame`）：提示词里已经写了 plain flat pure white background。**不要要求透明背景**：常常会画出假的灰白棋盘格，游戏导入时抠不掉。
  - 纯黑（`icon_`）：纯黑平底上的纯白剪影，符号后面没有圆圈或底板。
  - 画面本身（`bg_`、`cardart_`、`card_back`、`ui_`、`title_`）：完整画面铺满。

## 3. 选画风的三个方向

在 `reference_sheet` 后面各加一句：

- A 清透日系：`Lean towards clean Japanese anime cel shading: bright airy colors, crisp lineart, soft glowing highlights.`
- B 国风仙侠：`Lean towards ornate Chinese xianxia game painting: semi-thick painterly rendering, flowing silk, rich gold and jade accents.`
- C 哥特未来：`Lean towards dark gothic-futurist elegance: deeper contrast, black lace and filigree, more glowing circuitry and stained-glass light.`

用户选中后，把那一句存成 `style.clause`；用户写的意见译成英文存成 `style.note_en`。用户说"A 和 C 混一下"之类，就把两句合成一句。

## 4. 参考图（保持画风统一）

带参考图出图 = 调用 `image_gen` 时传 `referenced_image_paths`（**完整的绝对路径**，Windows 要带盘符，例如 `D:\chimera_art\style\style_ref.png`，不能用相对路径），并在提示词开头写：
`Image 1 is a STYLE REFERENCE only: match its art style, line quality, shading and coloring. Do not copy its characters, pose or composition. Create the new subject described below.`
（两张时再写 `Image 2 is also a style reference.`）

带参考图的调用在 Windows 上有已知问题：**最多 2 张**（3 张以上常报网络错误）；有时会卡住十几分钟，你在调用期间没法自己停下。规则：
- 每次带参考图出图**之前**，在 progress.json 写 `pending_ref_call` = 这一项的 id，并用 `Get-Date` 记下开始时间；出完马上清空。
- 下一轮发现 `pending_ref_call` 还在（上次卡住、用户点了停止），或者这次调用用了 3 分钟以上，或者报错 → 记 `refs_broken: true` 和日期，这一项改成不带参考图重出。
- `refs_broken` 为 true 时都不带参考图；过了一天、或者用户说"带参考图试试"时，再试一次。
- 不带参考图时，靠第 1 节第 2 句的风格方向保持统一，自检时更仔细地对比画风。
- 只用**当前画风下**通过的图当参考（换过风格后，旧画风的图不能当参考）。补图请求里写了"参照 xxx.png"的，就用 art_pack 里那张。

参考哪几张：

| 正在做 | 参考 |
|---|---|
| 我方角色（`body_`，不是反派）、部件（`part_`） | `style/style_ref.png` + 1 张已通过的同类图 |
| 反派（`villain`）、Boss | 1–2 张已通过的反派图（还没有就不用参考图），**不要**用风格参考图和我方角色 |
| 图标、背景、卡图、卡背、卡框、界面、标题图 | 1–2 张已通过的同类图（还没有就不用） |

同一个对话里出过的图也可能影响后面的图。从我方角色切到反派时，提示词里的反派句（第 1 节第 5 句）就是用来抵消这个影响的，不要省略。

## 5. 重画时怎么改

- 一次只改一件事：把问题写成一句英文加在末尾（例如 `Make her face clearly adult and more mature.`、`Remove all text.`、`Plain flat pure white background with no shadow.`）。
- 用户说"眼睛再大一点""颜色换成深蓝"之类，照译成英文加上。
- 小问题（一块阴影、一处杂色）可以改原图：调用 `image_gen` 时把这张图的绝对路径放进 `referenced_image_paths`，提示词写 "Image 1 is the edit target: change only X; keep everything else unchanged"。改出来的图另存为新的候选（`__v3.png`），不覆盖旧的。

## 6. 被拦截或者画得太幼

- 被内容政策拦截（报错里有 `moderation_blocked`）：不争辩，把服装描述改含蓄后**重出一次**，并告诉用户改了哪些词。替换表：
  alluring → elegant and charming；high side slit → elegant side slit；deep but tasteful neckline → modest elegant neckline；sheer / translucent → layered chiffon；off-shoulder → long elegant sleeves。
- 角色看起来太小、像孩子：女性加 `adult woman in her mid-twenties, mature face and proportions, tall`，男性加 `adult man in his late twenties, mature face, tall`。
- 改写后还被拦截：记为"跳过"（`skipped_reason` 里写明），告诉用户，继续做别的。被拦截的尝试可能也算额度，不要反复试。
