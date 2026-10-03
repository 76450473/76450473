# 美术资产提示词（全部 82 项）

进度：P1 0/40　P2 0/38　P3 0/4

怎么用：
1. 用任意 AI 生图工具（Midjourney / Stable Diffusion / 即梦 / 通义万相 / GPT 图像 …）复制下面的提示词生成。
   Midjourney：末尾加 `--ar 比例 --style raw --no 反向提示词`；出了满意的第一张后，后续都加 `--sref 它的链接`，保持风格统一。
   没有反向提示词栏的工具（GPT 图像等）：在提示词末尾加 `Avoid: 反向提示词`。
   即梦、通义万相、可灵：可以直接粘贴英文提示词；请关闭"智能扩写/提示词优化"，否则会自动加背景。
   能直接输出透明背景 PNG 的工具也可以用，导入时会自动识别。
2. 每张图按「保存为」的文件名放进项目的 `art_inbox/` 文件夹（png/jpg/webp 都行，名字对了最省事）。
3. 背景要求：灰度/去背景类用**纯白平底**，图标用**纯黑平底**；主体要有**粗深色描边**，这样才能自动抠图。
4. 在 `art_inbox/credits.txt` 写一行：用的工具/模型 + 授权（例如：Midjourney v7，付费订阅可商用）。
5. 对 Claude 说「导入美术」。它会处理、截图检查，并告诉你哪些要重做、还缺什么。
缺的资产不影响游戏运行——会自动用程序化占位美术代替。

## P1 · 先做（M1–M2 需要）

### 1. `body_biped` — 人形骨架（人族本体）
- 保存为：`art_inbox/body_biped.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：人族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline, whole body visible and filling most of the frame with a small margin, feet near the bottom, no weapons, no accessories, no extra organs, plain flat pure white background. Subject: a lean humanoid figure, bald head, simple wrapped cloth, both arms hanging. Shape language of this race: upright humanoid, symmetric, rounded rectangular forms, stitched leather and riveted metal details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 2. `body_cluster` — 菌簇骨架（菌族本体）
- 保存为：`art_inbox/body_cluster.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：菌族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline, whole body visible and filling most of the frame with a small margin, feet near the bottom, no weapons, no accessories, no extra organs, plain flat pure white background. Subject: a walking mushroom: thick pale stem body and a wide round cap, one small bulb at the base. Shape language of this race: fungal organism, swollen rounded blobs, mushroom caps, fibrous mycelium threads, soft spongy texture. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 3. `body_hexapod` — 六足骨架（虫族本体）
- 保存为：`art_inbox/body_hexapod.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：虫族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline, whole body visible and filling most of the frame with a small margin, feet near the bottom, no weapons, no accessories, no extra organs, plain flat pure white background. Subject: a six-legged beetle-like insect with abdomen, thorax, small head and two antennae. Shape language of this race: insectoid, segmented glossy chitin, sharp spikes, many jointed limbs. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 4. `part_banner` — 背负战旗（人族部件）
- 保存为：`art_inbox/part_banner.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：战旗
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a tall back-mounted war banner on a pole, tattered cloth flag. Shape language of this race: upright humanoid, symmetric, rounded rectangular forms, stitched leather and riveted metal details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 5. `part_bloom` — 尸花（菌族部件）
- 保存为：`art_inbox/part_bloom.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：尸花
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a six-petal corpse flower bloom. Shape language of this race: fungal organism, swollen rounded blobs, mushroom caps, fibrous mycelium threads, soft spongy texture. Only the flower center glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 6. `part_egg_sac` — 卵囊（虫族部件）
- 保存为：`art_inbox/part_egg_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：产卵管
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a cluster of four glossy insect eggs in a membrane. Shape language of this race: insectoid, segmented glossy chitin, sharp spikes, many jointed limbs. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 7. `part_eye_compound` — 复眼（虫族部件）
- 保存为：`art_inbox/part_eye_compound.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：复眼
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a cluster of bulging faceted compound insect eyes. Shape language of this race: insectoid, segmented glossy chitin, sharp spikes, many jointed limbs. Only the eye facets glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 8. `part_mandible` — 巨颚（虫族部件）
- 保存为：`art_inbox/part_mandible.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：巨颚
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a pair of curved serrated insect mandibles. Shape language of this race: insectoid, segmented glossy chitin, sharp spikes, many jointed limbs. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 9. `part_mycelium_web` — 菌丝网（菌族部件）
- 保存为：`art_inbox/part_mycelium_web.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：菌丝网
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a branching web of thin mycelium threads, roughly round patch. Shape language of this race: fungal organism, swollen rounded blobs, mushroom caps, fibrous mycelium threads, soft spongy texture. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 10. `part_plating` — 镶甲片（人族部件）
- 保存为：`art_inbox/part_plating.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：镶甲
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: three stacked riveted metal chest plates. Shape language of this race: upright humanoid, symmetric, rounded rectangular forms, stitched leather and riveted metal details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 11. `part_sac` — 毒腺囊（虫族部件）
- 保存为：`art_inbox/part_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：疫心、毒腺
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a translucent bulbous venom gland sac with veins. Shape language of this race: insectoid, segmented glossy chitin, sharp spikes, many jointed limbs. Only the liquid inside the sac glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 12. `part_sash` — 肩带（人族部件）
- 保存为：`art_inbox/part_sash.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：协同操练
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a diagonal cloth sash with a small rally badge, laid flat as if worn across a chest. Shape language of this race: upright humanoid, symmetric, rounded rectangular forms, stitched leather and riveted metal details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 13. `part_satchel` — 急救挎包（人族部件）
- 保存为：`art_inbox/part_satchel.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：战地包扎
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a small leather field-medic satchel with a strap and a cross mark. Shape language of this race: upright humanoid, symmetric, rounded rectangular forms, stitched leather and riveted metal details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 14. `part_shell_plate` — 背甲壳片（虫族部件）
- 保存为：`art_inbox/part_shell_plate.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：甲壳
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a row of four overlapping curved chitin shell plates. Shape language of this race: insectoid, segmented glossy chitin, sharp spikes, many jointed limbs. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 15. `part_spear` — 长矛（人族部件）
- 保存为：`art_inbox/part_spear.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：长矛
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a long wooden spear held diagonally, metal leaf-shaped spearhead pointing up-right. Shape language of this race: upright humanoid, symmetric, rounded rectangular forms, stitched leather and riveted metal details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 16. `part_spore_cap` — 孢子冠（菌族部件）
- 保存为：`art_inbox/part_spore_cap.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：孢子囊
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: three small mushroom caps on short stalks, growing together. Shape language of this race: fungal organism, swollen rounded blobs, mushroom caps, fibrous mycelium threads, soft spongy texture. Only the spots on the caps glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 17. `part_spray_nozzle` — 喷射器官（虫族部件）
- 保存为：`art_inbox/part_spray_nozzle.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：喷射器官
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a chitinous tube-shaped spray nozzle organ dripping liquid. Shape language of this race: insectoid, segmented glossy chitin, sharp spikes, many jointed limbs. Only the dripping liquid glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 18. `part_tendril` — 腐触须（菌族部件）
- 保存为：`art_inbox/part_tendril.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：腐触
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a single wavy fungal tentacle tendril, tapering to a thin tip. Shape language of this race: fungal organism, swollen rounded blobs, mushroom caps, fibrous mycelium threads, soft spongy texture. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 19. `part_volatile_sac` — 爆裂囊（虫族部件）
- 保存为：`art_inbox/part_volatile_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：死亡爆裂
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a swollen unstable explosive gland sac with cracks. Shape language of this race: insectoid, segmented glossy chitin, sharp spikes, many jointed limbs. Only the cracks and the core glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 20. `bg_swamp` — 战斗背景·腐沼
- 保存为：`art_inbox/bg_swamp.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：腐沼
- 提示词：

```text
2D side-view game battle background, dark biological fantasy, painterly, muted desaturated colors, horizon in the upper third, wide calm flat ground band across the middle and lower half where creatures will stand, darker and low-contrast in the center, atmospheric depth, no characters, no creatures, no text, no UI. Scene: a rotting toxic swamp: dead twisted trees, glowing green fungus, murky water pools, hanging moss, sickly green fog.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 21. `icon_energy` — 能量
- 保存为：`art_inbox/icon_energy.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a glowing round nucleus orb with a small ring.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 22. `icon_map_battle` — 地图·战斗
- 保存为：`art_inbox/icon_map_battle.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: two crossed claws.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 23. `icon_map_boss` — 地图·Boss
- 保存为：`art_inbox/icon_map_boss.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a jagged crown.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 24. `icon_map_elite` — 地图·精英
- 保存为：`art_inbox/icon_map_elite.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a horned beast skull.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 25. `icon_map_event` — 地图·事件
- 保存为：`art_inbox/icon_map_event.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a question mark made of vines.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 26. `icon_map_habitat` — 地图·栖息地
- 保存为：`art_inbox/icon_map_habitat.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a nest with eggs.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 27. `icon_map_market` — 地图·黑市
- 保存为：`art_inbox/icon_map_market.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a balance scale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 28. `icon_map_mutation` — 地图·异变池
- 保存为：`art_inbox/icon_map_mutation.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a bubbling cauldron.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 29. `icon_map_ruin` — 地图·遗迹融合台
- 保存为：`art_inbox/icon_map_ruin.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a DNA double helix over an altar.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 30. `icon_stat_armor` — 数值·护甲
- 保存为：`art_inbox/icon_stat_armor.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a chitin shield plate.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 31. `icon_stat_atk` — 数值·攻击
- 保存为：`art_inbox/icon_stat_atk.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a single curved fang.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 32. `icon_stat_hp` — 数值·生命
- 保存为：`art_inbox/icon_stat_hp.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: an anatomical heart.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 33. `icon_stat_spd` — 数值·速度
- 保存为：`art_inbox/icon_stat_spd.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: an insect wing.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 34. `icon_status_infect` — 状态·感染
- 保存为：`art_inbox/icon_status_infect.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a cluster of five round spores.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 35. `icon_status_poison` — 状态·毒
- 保存为：`art_inbox/icon_status_poison.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a single venom droplet.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 36. `icon_status_regen` — 状态·再生
- 保存为：`art_inbox/icon_status_regen.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a rounded plus cross made of living tissue.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 37. `icon_status_stun` — 状态·眩晕
- 保存为：`art_inbox/icon_status_stun.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a spinning four-pointed star with motion arcs.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 38. `icon_status_vulnerable` — 状态·易伤
- 保存为：`art_inbox/icon_status_vulnerable.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a cracked broken shield.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 39. `card_back` — 卡背
- 保存为：`art_inbox/card_back.png`　｜　比例 5:7（建议 1024×1434）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
dark biological fantasy game UI element, aged parchment, bone and dark chitin, ink line details, flat front view, no text. the back of a trading card, symmetric emblem of a DNA helix entwined with a chitin spiral, dark parchment, fills the whole image.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 40. `card_frame` — 卡牌边框
- 保存为：`art_inbox/card_frame.png`　｜　比例 5:7（建议 1024×1434）　｜　背景：纯白　｜　模式：彩色，去背景
- 提示词：

```text
dark biological fantasy game UI element, aged parchment, bone and dark chitin, ink line details, flat front view, no text. an ornate vertical trading card frame made of bone, dark chitin and parchment, a large empty window in the upper half and a smaller empty text box in the lower half, both windows filled with flat pure white, plain flat pure white background outside the frame.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

## P2 · 其次（M3–M5）

### 41. `body_construct` — 晶构骨架（晶族本体）
- 保存为：`art_inbox/body_construct.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：晶族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline, whole body visible and filling most of the frame with a small margin, feet near the bottom, no weapons, no accessories, no extra organs, plain flat pure white background. Subject: a floating crystal golem: faceted diamond torso, small gem head, shard arms, a shard floating below instead of legs. Shape language of this race: living crystal construct, faceted geometric shards, sharp angles, translucent glassy planes. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 42. `body_floater` — 漂浮骨架（幽体本体）
- 保存为：`art_inbox/body_floater.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：幽体
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline, whole body visible and filling most of the frame with a small margin, feet near the bottom, no weapons, no accessories, no extra organs, plain flat pure white background. Subject: a floating hooded ghost with a teardrop body and a long wispy tail, two empty glowing eyes. Shape language of this race: ghostly wraith, floating hooded shape, frayed trailing wisps, hollow eyes, semi-transparent. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 43. `body_quadruped` — 四足骨架（兽族本体）
- 保存为：`art_inbox/body_quadruped.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：兽族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline, whole body visible and filling most of the frame with a small margin, feet near the bottom, no weapons, no accessories, no extra organs, plain flat pure white background. Subject: a four-legged predator beast like a wolf, long tail, head facing right. Shape language of this race: feral beast, heavy muscles, bone, coarse fur, horns and claws. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 44. `part_claw` — 利爪（兽族部件）
- 保存为：`art_inbox/part_claw.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：扑击
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: three curved bone claws on a paw, pointing right. Shape language of this race: feral beast, heavy muscles, bone, coarse fur, horns and claws. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 45. `part_core_gem` — 共鸣晶核（晶族部件）
- 保存为：`art_inbox/part_core_gem.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：共鸣核
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a hexagonal faceted resonance gem. Shape language of this race: living crystal construct, faceted geometric shards, sharp angles, translucent glassy planes. Only the gem glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 46. `part_crest` — 头冠（兽族部件）
- 保存为：`art_inbox/part_crest.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：狼嚎
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a crest of three sharp horn-like spikes. Shape language of this race: feral beast, heavy muscles, bone, coarse fur, horns and claws. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 47. `part_crystal_cluster` — 晶簇（晶族部件）
- 保存为：`art_inbox/part_crystal_cluster.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：晶格
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a cluster of four sharp crystal shards of different heights. Shape language of this race: living crystal construct, faceted geometric shards, sharp angles, translucent glassy planes. Only the inner glow of the shards glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 48. `part_ether_veil` — 灵体纱（幽体部件）
- 保存为：`art_inbox/part_ether_veil.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：灵体
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a long flowing frayed ghostly veil cloak, hanging vertically. Shape language of this race: ghostly wraith, floating hooded shape, frayed trailing wisps, hollow eyes, semi-transparent. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 49. `part_fang` — 尖牙（兽族部件）
- 保存为：`art_inbox/part_fang.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：尖牙
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a pair of long curved animal fangs. Shape language of this race: feral beast, heavy muscles, bone, coarse fur, horns and claws. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 50. `part_fur_mane` — 鬃毛（兽族部件）
- 保存为：`art_inbox/part_fur_mane.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：厚皮
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a ridge of spiky coarse fur tufts, like a mane. Shape language of this race: feral beast, heavy muscles, bone, coarse fur, horns and claws. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 51. `part_halo` — 幽光冕（幽体部件）
- 保存为：`art_inbox/part_halo.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：恐惧尖啸
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a thin double ghostly ring halo seen at a slight angle. Shape language of this race: ghostly wraith, floating hooded shape, frayed trailing wisps, hollow eyes, semi-transparent. Only the rings glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 52. `part_prism` — 折射棱镜（晶族部件）
- 保存为：`art_inbox/part_prism.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：折射棱镜
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: a single triangular crystal prism. Shape language of this race: living crystal construct, faceted geometric shards, sharp angles, translucent glassy planes. Only the light at the prism center glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 53. `part_soul_claw` — 噬魂爪（幽体部件）
- 保存为：`art_inbox/part_soul_claw.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：噬魂
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, forbidden naturalist bestiary style, single isolated creature part, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background. Subject: three long ghostly spectral claw streaks. Shape language of this race: ghostly wraith, floating hooded shape, frayed trailing wisps, hollow eyes, semi-transparent. Only the claw streaks glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 54. `bg_glacier` — 战斗背景·冰原
- 保存为：`art_inbox/bg_glacier.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：冰原
- 提示词：

```text
2D side-view game battle background, dark biological fantasy, painterly, muted desaturated colors, horizon in the upper third, wide calm flat ground band across the middle and lower half where creatures will stand, darker and low-contrast in the center, atmospheric depth, no characters, no creatures, no text, no UI. Scene: a frozen glacier plateau: blue ice cliffs, crystal formations jutting from snow, pale cold sky, frost mist.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 55. `bg_hive` — 战斗背景·巢穴深处
- 保存为：`art_inbox/bg_hive.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：巢穴深处
- 提示词：

```text
2D side-view game battle background, dark biological fantasy, painterly, muted desaturated colors, horizon in the upper third, wide calm flat ground band across the middle and lower half where creatures will stand, darker and low-contrast in the center, atmospheric depth, no characters, no creatures, no text, no UI. Scene: the depths of a giant insect hive: organic resin walls, honeycomb chambers, faint violet ghost lights, dripping secretions.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 56. `icon_emblem_beast` — 族徽·兽族
- 保存为：`art_inbox/icon_emblem_beast.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a wolf paw print.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 57. `icon_emblem_crystal` — 族徽·晶族
- 保存为：`art_inbox/icon_emblem_crystal.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a faceted crystal shard.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 58. `icon_emblem_fungal` — 族徽·菌族
- 保存为：`art_inbox/icon_emblem_fungal.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a mushroom.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 59. `icon_emblem_human` — 族徽·人族
- 保存为：`art_inbox/icon_emblem_human.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: an open hand holding a spear.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 60. `icon_emblem_insect` — 族徽·虫族
- 保存为：`art_inbox/icon_emblem_insect.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a beetle seen from above.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 61. `icon_emblem_wraith` — 族徽·幽体
- 保存为：`art_inbox/icon_emblem_wraith.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a hooded ghost mask.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 62. `icon_slot_back` — 插槽·背
- 保存为：`art_inbox/icon_slot_back.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a spine with dorsal spikes.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 63. `icon_slot_core` — 插槽·核
- 保存为：`art_inbox/icon_slot_core.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a cell with a nucleus.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 64. `icon_slot_head` — 插槽·头
- 保存为：`art_inbox/icon_slot_head.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a creature skull seen from the side.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 65. `icon_slot_limb` — 插槽·肢
- 保存为：`art_inbox/icon_slot_limb.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a bent jointed limb.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 66. `icon_slot_skin` — 插槽·皮
- 保存为：`art_inbox/icon_slot_skin.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a patch of scales.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 67. `title_art` — 标题画面主视觉
- 保存为：`art_inbox/title_art.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. key art: a hybrid chimera creature with human posture, insect chitin, fungal growths and crystal shards, standing on a cliff over a vast alien ecosystem, a giant withered tree of life in the sky, epic but dark, space at the top for a logo.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 68. `ui_button` — 按钮
- 保存为：`art_inbox/ui_button.png`　｜　比例 3:1（建议 1536×512）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
dark biological fantasy game UI element, aged parchment, bone and dark chitin, ink line details, flat front view, no text. a wide rounded game button plate made of dark chitin with a thin bone rim, empty center, fills the whole image.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 69. `ui_panel` — 界面面板（九宫格）
- 保存为：`art_inbox/ui_panel.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
dark biological fantasy game UI element, aged parchment, bone and dark chitin, ink line details, flat front view, no text. a square dark parchment panel with an even bone-and-ink border of constant width on all four sides, plain empty center, fills the whole image.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 70. `boss_rotbrood_matriarch` — 腐巢母皇（Boss 立绘）
- 保存为：`art_inbox/boss_rotbrood_matriarch.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：腐巢母皇
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Full body side view facing left, isolated, plain flat pure white background. Subject: a colossal fungal-insect matriarch: a bloated mushroom-capped body, insect legs, translucent egg sacs on her back with larvae inside, spores drifting, menacing but regal.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 71. `cardart_card_analyze` — 卡图·解析标记
- 保存为：`art_inbox/cardart_card_analyze.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：解析标记
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Card illustration, landscape composition. Subject: a scanning beam revealing hidden organs inside a creature, anatomical diagram style.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 72. `cardart_card_brood` — 卡图·催化孵化
- 保存为：`art_inbox/cardart_card_brood.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：催化孵化
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Card illustration, landscape composition. Subject: eggs bursting open as larvae hatch rapidly.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 73. `cardart_card_harden` — 卡图·硬化
- 保存为：`art_inbox/cardart_card_harden.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：硬化
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Card illustration, landscape composition. Subject: skin rapidly hardening into thick chitin plates.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 74. `cardart_card_mend` — 卡图·组织修复
- 保存为：`art_inbox/cardart_card_mend.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：组织修复
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Card illustration, landscape composition. Subject: glowing tissue knitting a wound closed.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 75. `cardart_card_rally` — 卡图·集群信息素
- 保存为：`art_inbox/cardart_card_rally.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：集群信息素
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Card illustration, landscape composition. Subject: a swarm of creatures surrounded by drifting pheromone trails, rallying.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 76. `cardart_card_strike` — 卡图·撕咬号令
- 保存为：`art_inbox/cardart_card_strike.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：撕咬号令
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Card illustration, landscape composition. Subject: a predator lunging forward to bite, motion lines, close-up on jaws.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 77. `cardart_card_stun` — 卡图·震慑
- 保存为：`art_inbox/cardart_card_stun.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：震慑
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Card illustration, landscape composition. Subject: a monstrous roar shockwave rippling through the air.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

### 78. `cardart_card_toxin` — 卡图·毒雾
- 保存为：`art_inbox/cardart_card_toxin.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：毒雾
- 提示词：

```text
dark biological fantasy illustration, forbidden naturalist bestiary page, ink outlines with painterly color, muted parchment tones with bioluminescent accents, readable silhouette, no text, no watermark. Card illustration, landscape composition. Subject: a rolling cloud of green toxic fog over a battlefield.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, watermark, signature, logo, blurry`

## P3 · 锦上添花

### 79. `icon_fx_droplet` — 特效·液滴
- 保存为：`art_inbox/icon_fx_droplet.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a liquid droplet.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 80. `icon_fx_slash` — 特效·斩击
- 保存为：`art_inbox/icon_fx_slash.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a curved slash streak.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 81. `icon_fx_spark` — 特效·火花
- 保存为：`art_inbox/icon_fx_spark.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a four-pointed spark.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`

### 82. `icon_fx_spore` — 特效·孢子粒
- 保存为：`art_inbox/icon_fx_spore.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no outline color, no gradient, no border, no text. Symbol: a soft round spore particle.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, watermark, signature, logo, multiple objects, scene, background details, cast shadow, frame, cropped, blurry, low contrast outline`
