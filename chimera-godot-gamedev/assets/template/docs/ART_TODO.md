# 缺失的美术资产（82 项）

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
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole silhouette, whole body visible and filling most of the frame with a small margin, the lowest point of the body near the bottom edge, no weapons, no accessories, no extra organs, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a lean humanoid figure, bald head, simple wrapped cloth, both arms hanging. Surface materials: symmetric rounded rectangular forms, stitched leather, rough cloth and riveted iron details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 2. `body_cluster` — 菌簇骨架（菌族本体）
- 保存为：`art_inbox/body_cluster.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：菌族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole silhouette, whole body visible and filling most of the frame with a small margin, the lowest point of the body near the bottom edge, no weapons, no accessories, no extra organs, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a walking mushroom: thick pale stem body and a wide round cap, one small bulb at the base. Surface materials: swollen rounded fungal flesh, soft spongy texture, fine fibrous thread details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 3. `body_hexapod` — 六足骨架（虫族本体）
- 保存为：`art_inbox/body_hexapod.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：虫族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole silhouette, whole body visible and filling most of the frame with a small margin, the lowest point of the body near the bottom edge, no weapons, no accessories, no extra organs, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a six-legged beetle-like insect with abdomen, thorax, small head and two antennae. Surface materials: segmented glossy chitin plates with small sharp spikes. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 4. `part_banner` — 背负战旗（人族部件）
- 保存为：`art_inbox/part_banner.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：战旗
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a tall vertical pole standing upright with a tattered cloth war flag hanging from its top on the left side, the pole's bottom end at the bottom of the image, no person. Surface materials: symmetric rounded rectangular forms, stitched leather, rough cloth and riveted iron details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 5. `part_bloom` — 尸花（菌族部件）
- 保存为：`art_inbox/part_bloom.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：尸花
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single six-petal corpse flower head seen from the front, no stem, no leaves. Surface materials: swollen rounded fungal flesh, soft spongy texture, fine fibrous thread details. Only the flower center glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 6. `part_egg_sac` — 卵囊（虫族部件）
- 保存为：`art_inbox/part_egg_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：产卵管
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a compact cluster of four glossy insect eggs held together in a membrane. Surface materials: segmented glossy chitin plates with small sharp spikes. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 7. `part_eye_compound` — 复眼（虫族部件）
- 保存为：`art_inbox/part_eye_compound.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：复眼
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a cluster of bulging faceted compound insect eyes, seen from the side, no head. Surface materials: segmented glossy chitin plates with small sharp spikes. Only a small glint at the center of each facet glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 8. `part_mandible` — 巨颚（虫族部件）
- 保存为：`art_inbox/part_mandible.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：巨颚
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a pair of curved serrated insect mandibles seen from the side, their joint base at the left edge, the open pincers pointing to the right, no head. Surface materials: segmented glossy chitin plates with small sharp spikes. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 9. `part_mycelium_web` — 菌丝网（菌族部件）
- 保存为：`art_inbox/part_mycelium_web.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：菌丝网
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a solid, roughly round flat patch of dense felted mycelium mat, opaque like lichen, fibrous thread texture painted on its surface, a few short thread tufts along its edge, no holes or gaps. Surface materials: swollen rounded fungal flesh, soft spongy texture, fine fibrous thread details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 10. `part_plating` — 镶甲片（人族部件）
- 保存为：`art_inbox/part_plating.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：镶甲
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: three stacked riveted metal armor plates lying flat, the plates alone with no body or torso. Surface materials: symmetric rounded rectangular forms, stitched leather, rough cloth and riveted iron details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 11. `part_sac` — 毒腺囊（虫族部件）
- 保存为：`art_inbox/part_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：疫心、毒腺
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single translucent bulbous venom gland sac with veins, the organ alone. Surface materials: segmented glossy chitin plates with small sharp spikes. Only the small pool of liquid in the lower half of the sac glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 12. `part_sash` — 肩带（人族部件）
- 保存为：`art_inbox/part_sash.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：协同操练
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single diagonal strip of cloth sash lying flat, running from upper left to lower right, with a small round rally badge pinned on it, the sash alone with no person or body. Surface materials: symmetric rounded rectangular forms, stitched leather, rough cloth and riveted iron details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 13. `part_satchel` — 急救挎包（人族部件）
- 保存为：`art_inbox/part_satchel.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：战地包扎
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a small leather field-medic satchel with a short strap stub and a cross mark, the bag alone. Surface materials: symmetric rounded rectangular forms, stitched leather, rough cloth and riveted iron details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 14. `part_shell_plate` — 背甲壳片（虫族部件）
- 保存为：`art_inbox/part_shell_plate.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：甲壳
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a short row of four overlapping curved chitin shell plates, about twice as wide as tall. Surface materials: segmented glossy chitin plates with small sharp spikes. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 15. `part_spear` — 长矛（人族部件）
- 保存为：`art_inbox/part_spear.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：长矛
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a long wooden spear lying diagonally from lower left to upper right, leaf-shaped metal spearhead at the upper right end, the weapon alone with no hand or arm. Surface materials: symmetric rounded rectangular forms, stitched leather, rough cloth and riveted iron details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 16. `part_spore_cap` — 孢子冠（菌族部件）
- 保存为：`art_inbox/part_spore_cap.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：孢子囊
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: three small mushroom caps on short stalks growing upward from one shared base at the bottom. Surface materials: swollen rounded fungal flesh, soft spongy texture, fine fibrous thread details. Only the spots on the caps glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 17. `part_spray_nozzle` — 喷射器官（虫族部件）
- 保存为：`art_inbox/part_spray_nozzle.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：喷射器官
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a short chitinous tube-shaped spray nozzle organ lying horizontally, its wide base at the left edge and its opening pointing right, one drop of liquid at the opening. Surface materials: segmented glossy chitin plates with small sharp spikes. Only the dripping liquid glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 18. `part_tendril` — 腐触须（菌族部件）
- 保存为：`art_inbox/part_tendril.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：腐触
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single thick fungal tentacle tendril growing horizontally to the right from a fleshy rounded base at the left edge, gently curling, tapering to a thin hooked tip at the right end, about twice as long as it is tall. Surface materials: swollen rounded fungal flesh, soft spongy texture, fine fibrous thread details. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 19. `part_volatile_sac` — 爆裂囊（虫族部件）
- 保存为：`art_inbox/part_volatile_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：死亡爆裂
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a swollen unstable explosive gland sac with glowing cracks, the organ alone. Surface materials: segmented glossy chitin plates with small sharp spikes. Only the cracks and the core glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 20. `bg_swamp` — 战斗背景·腐沼
- 保存为：`art_inbox/bg_swamp.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：腐沼
- 提示词：

```text
2D side-view game battle background, dark biological fantasy, painterly, muted desaturated colors, horizon in the upper third, wide calm flat empty ground band across the middle and lower half left open for gameplay, darker and low-contrast in the center, atmospheric depth, empty uninhabited landscape, no text, no UI, no border. Scene: a rotting toxic swamp: dead twisted trees, glowing green fungus, murky water pools, hanging moss, sickly green fog.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry, characters, creatures, animals, people, monsters, UI`

### 21. `icon_energy` — 能量
- 保存为：`art_inbox/icon_energy.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a round nucleus orb with a small orbit ring.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 22. `icon_map_battle` — 地图·战斗
- 保存为：`art_inbox/icon_map_battle.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: two crossed claws.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 23. `icon_map_boss` — 地图·Boss
- 保存为：`art_inbox/icon_map_boss.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a jagged crown.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 24. `icon_map_elite` — 地图·精英
- 保存为：`art_inbox/icon_map_elite.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a horned beast skull.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 25. `icon_map_event` — 地图·事件
- 保存为：`art_inbox/icon_map_event.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a question mark made of vines.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 26. `icon_map_habitat` — 地图·栖息地
- 保存为：`art_inbox/icon_map_habitat.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a nest with eggs.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 27. `icon_map_market` — 地图·黑市
- 保存为：`art_inbox/icon_map_market.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a balance scale.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 28. `icon_map_mutation` — 地图·异变池
- 保存为：`art_inbox/icon_map_mutation.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a bubbling cauldron.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 29. `icon_map_ruin` — 地图·遗迹融合台
- 保存为：`art_inbox/icon_map_ruin.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a DNA double helix over an altar.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 30. `icon_stat_armor` — 数值·护甲
- 保存为：`art_inbox/icon_stat_armor.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a chitin shield plate.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 31. `icon_stat_atk` — 数值·攻击
- 保存为：`art_inbox/icon_stat_atk.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a single curved fang.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 32. `icon_stat_hp` — 数值·生命
- 保存为：`art_inbox/icon_stat_hp.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: an anatomical heart.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 33. `icon_stat_spd` — 数值·速度
- 保存为：`art_inbox/icon_stat_spd.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: an insect wing.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 34. `icon_status_infect` — 状态·感染
- 保存为：`art_inbox/icon_status_infect.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a cluster of five round spores.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 35. `icon_status_poison` — 状态·毒
- 保存为：`art_inbox/icon_status_poison.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a single venom droplet.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 36. `icon_status_regen` — 状态·再生
- 保存为：`art_inbox/icon_status_regen.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a rounded plus cross made of living tissue.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 37. `icon_status_stun` — 状态·眩晕
- 保存为：`art_inbox/icon_status_stun.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a spinning four-pointed star with motion arcs.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 38. `icon_status_vulnerable` — 状态·易伤
- 保存为：`art_inbox/icon_status_vulnerable.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a cracked broken shield.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 39. `card_back` — 卡背
- 保存为：`art_inbox/card_back.png`　｜　比例 5:7（建议 1024×1434）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
dark biological fantasy game UI element, aged parchment, bone and dark chitin, ink line details, flat front view, no text. full-bleed card back design filling the whole image edge to edge, symmetric emblem of a DNA helix entwined with a chitin spiral on dark parchment, no rounded corners, no table, no shadow.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, numbers, handwriting, watermark, signature, logo, characters, creatures, blurry`

### 40. `card_frame` — 卡牌边框
- 保存为：`art_inbox/card_frame.png`　｜　比例 5:7（建议 1024×1434）　｜　背景：纯白　｜　模式：彩色，去背景
- 提示词：

```text
dark biological fantasy game UI element, aged parchment, bone and dark chitin, ink line details, flat front view, no text. an ornate vertical trading card frame made of bone and dark chitin, a thick dark outline around its outer edge and around each window; one large empty art window in the middle of the card, from about 12% to 62% of the card height so that it covers the exact center of the image, filled with flat pure white; below it a smaller text box filled with light aged parchment (not white); plain flat pure white background outside the frame.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, numbers, handwriting, watermark, signature, logo, characters, creatures, blurry`

## P2 · 其次（M3–M5）

### 41. `body_construct` — 晶构骨架（晶族本体）
- 保存为：`art_inbox/body_construct.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：晶族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole silhouette, whole body visible and filling most of the frame with a small margin, the lowest point of the body near the bottom edge, no weapons, no accessories, no extra organs, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a floating crystal golem: faceted diamond torso, small gem head, shard arms, a single shard floating below instead of legs. Surface materials: faceted geometric crystal, sharp angles, glassy translucent planes. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 42. `body_floater` — 漂浮骨架（幽体本体）
- 保存为：`art_inbox/body_floater.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：幽体
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole silhouette, whole body visible and filling most of the frame with a small margin, the lowest point of the body near the bottom edge, no weapons, no accessories, no extra organs, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a floating hooded ghost with a teardrop body and a long wispy tail curling below, two hollow dark eye holes. Surface materials: pale misty ectoplasm with softly frayed edges, still enclosed by the dark outline. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 43. `body_quadruped` — 四足骨架（兽族本体）
- 保存为：`art_inbox/body_quadruped.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：兽族
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, full body of a creature in its plain base form, side view facing right, neutral idle pose, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole silhouette, whole body visible and filling most of the frame with a small margin, the lowest point of the body near the bottom edge, no weapons, no accessories, no extra organs, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a four-legged predator beast like a wolf, long tail, head facing right. Surface materials: rough bone, horn and coarse fur textures. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 44. `part_claw` — 利爪（兽族部件）
- 保存为：`art_inbox/part_claw.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：扑击
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: three curved bone claws on a small paw stub, the paw at the left edge, the claws pointing to the right. Surface materials: rough bone, horn and coarse fur textures. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 45. `part_core_gem` — 共鸣晶核（晶族部件）
- 保存为：`art_inbox/part_core_gem.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：共鸣核
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single hexagonal faceted resonance gem. Surface materials: faceted geometric crystal, sharp angles, glassy translucent planes. Only the small bright core at the gem's center glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 46. `part_crest` — 头冠（兽族部件）
- 保存为：`art_inbox/part_crest.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：狼嚎
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a crest of three sharp horn-like spikes rising upward from one shared base at the bottom. Surface materials: rough bone, horn and coarse fur textures. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 47. `part_crystal_cluster` — 晶簇（晶族部件）
- 保存为：`art_inbox/part_crystal_cluster.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：晶格
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a cluster of four sharp crystal shards of different heights growing upward from one shared base at the bottom. Surface materials: faceted geometric crystal, sharp angles, glassy translucent planes. Only a thin glowing line along the center of each shard glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 48. `part_ether_veil` — 灵体纱（幽体部件）
- 保存为：`art_inbox/part_ether_veil.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：灵体
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a long flowing frayed ghostly veil cloak hanging vertically, top edge straight, lower edge in ragged tatters, the cloth alone with no person. Surface materials: pale misty ectoplasm with softly frayed edges, still enclosed by the dark outline. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 49. `part_fang` — 尖牙（兽族部件）
- 保存为：`art_inbox/part_fang.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：尖牙
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a pair of long curved animal fangs hanging downward side by side, roots at the top, sharp tips pointing down, no jaw or skull. Surface materials: rough bone, horn and coarse fur textures. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 50. `part_fur_mane` — 鬃毛（兽族部件）
- 保存为：`art_inbox/part_fur_mane.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：厚皮
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a ridge of spiky coarse fur tufts rising upward from a straight base line at the bottom, like a mane seen from the side. Surface materials: rough bone, horn and coarse fur textures. No glowing or colored areas at all; strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 51. `part_halo` — 幽光冕（幽体部件）
- 保存为：`art_inbox/part_halo.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：恐惧尖啸
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single thick ring halo of ghostly light seen almost edge-on from the side, a flat wide elliptical ring about twice as wide as it is tall, broken by a clear gap at the bottom so the white background inside the ring connects to the outside. Surface materials: pale misty ectoplasm with softly frayed edges, still enclosed by the dark outline. Only the inner edge of the ring glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 52. `part_prism` — 折射棱镜（晶族部件）
- 保存为：`art_inbox/part_prism.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：折射棱镜
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single upright triangular crystal prism standing on its flat base, point upward. Surface materials: faceted geometric crystal, sharp angles, glassy translucent planes. Only the light at the prism center glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 53. `part_soul_claw` — 噬魂爪（幽体部件）
- 保存为：`art_inbox/part_soul_claw.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：灰度（游戏内自动上色，只有发光处用鲜绿）
- 用在：噬魂
- 提示词：

```text
2D game asset for a creature-assembly game, dark biological fantasy, dark naturalist illustration style, a single isolated creature part shown on its own, not attached to any body, side view facing right, monochrome grayscale value painting, flat cel shading with one soft highlight, thick closed uniform near-black outline around the whole shape, clean readable silhouette, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: three long ghostly spectral claw blades fanning out to the right from one shared root at the left edge. Surface materials: pale misty ectoplasm with softly frayed edges, still enclosed by the dark outline. Only the claw tips glow in a bright saturated green; everything else stays strictly grayscale.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, blood splatter, text, letters, labels, handwriting, watermark, signature, logo, multiple objects, extra creature, hands, scene, background details, ground, cast shadow, frame, border, cropped, blurry, low contrast outline`

### 54. `bg_glacier` — 战斗背景·冰原
- 保存为：`art_inbox/bg_glacier.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：冰原
- 提示词：

```text
2D side-view game battle background, dark biological fantasy, painterly, muted desaturated colors, horizon in the upper third, wide calm flat empty ground band across the middle and lower half left open for gameplay, darker and low-contrast in the center, atmospheric depth, empty uninhabited landscape, no text, no UI, no border. Scene: a frozen glacier plateau: blue ice cliffs, crystal formations jutting from snow, pale cold sky, frost mist.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry, characters, creatures, animals, people, monsters, UI`

### 55. `bg_hive` — 战斗背景·巢穴深处
- 保存为：`art_inbox/bg_hive.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：巢穴深处
- 提示词：

```text
2D side-view game battle background, dark biological fantasy, painterly, muted desaturated colors, horizon in the upper third, wide calm flat empty ground band across the middle and lower half left open for gameplay, darker and low-contrast in the center, atmospheric depth, empty uninhabited landscape, no text, no UI, no border. Scene: the depths of a giant insect hive: organic resin walls, honeycomb chambers, faint violet ghost lights, dripping secretions.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry, characters, creatures, animals, people, monsters, UI`

### 56. `icon_emblem_beast` — 族徽·兽族
- 保存为：`art_inbox/icon_emblem_beast.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a wolf paw print.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 57. `icon_emblem_crystal` — 族徽·晶族
- 保存为：`art_inbox/icon_emblem_crystal.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a faceted crystal shard.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 58. `icon_emblem_fungal` — 族徽·菌族
- 保存为：`art_inbox/icon_emblem_fungal.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a mushroom.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 59. `icon_emblem_human` — 族徽·人族
- 保存为：`art_inbox/icon_emblem_human.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a raised fist gripping an upright spear.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 60. `icon_emblem_insect` — 族徽·虫族
- 保存为：`art_inbox/icon_emblem_insect.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a beetle seen from above.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 61. `icon_emblem_wraith` — 族徽·幽体
- 保存为：`art_inbox/icon_emblem_wraith.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a hooded ghost mask.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 62. `icon_slot_back` — 插槽·背
- 保存为：`art_inbox/icon_slot_back.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a spine with dorsal spikes.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 63. `icon_slot_core` — 插槽·核
- 保存为：`art_inbox/icon_slot_core.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a cell with a nucleus.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 64. `icon_slot_head` — 插槽·头
- 保存为：`art_inbox/icon_slot_head.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a creature skull seen from the side.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 65. `icon_slot_limb` — 插槽·肢
- 保存为：`art_inbox/icon_slot_limb.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a bent jointed limb.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 66. `icon_slot_skin` — 插槽·皮
- 保存为：`art_inbox/icon_slot_skin.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a patch of scales.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 67. `title_art` — 标题画面主视觉
- 保存为：`art_inbox/title_art.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. key art: a hybrid chimera creature with human posture, insect chitin, fungal growths and crystal shards, standing on a cliff over a vast alien ecosystem, a giant withered tree of life in the sky, epic but dark, empty dark sky in the upper third.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

### 68. `ui_button` — 按钮
- 保存为：`art_inbox/ui_button.png`　｜　比例 3:1（建议 1536×512）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
dark biological fantasy game UI element, aged parchment, bone and dark chitin, ink line details, flat front view, no text. a rectangular game button plate made of dark chitin with a thin bone rim, filling the whole image edge to edge with square corners, empty center.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, numbers, handwriting, watermark, signature, logo, characters, creatures, blurry`

### 69. `ui_panel` — 界面面板（九宫格）
- 保存为：`art_inbox/ui_panel.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
dark biological fantasy game UI element, aged parchment, bone and dark chitin, ink line details, flat front view, no text. a square dark parchment panel filling the whole image edge to edge, an even bone-and-ink border of constant width on all four sides, plain empty center, square corners.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, numbers, handwriting, watermark, signature, logo, characters, creatures, blurry`

### 70. `boss_rotbrood_matriarch` — 腐巢母皇（Boss 立绘）
- 保存为：`art_inbox/boss_rotbrood_matriarch.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：腐巢母皇
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full body side view facing left, isolated, thick closed dark outline around the whole silhouette, plain flat pure white background, no ground, no cast shadow. Subject: a colossal fungal-insect matriarch: a bloated mushroom-capped body, insect legs, dark-shelled egg sacs on her back, small glowing spore dots speckling her cap, menacing but regal, no loose particles or floating specks.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry, ground, floor, cast shadow, drop shadow, scenery, background details, extra creatures, smoke, clouds, loose particles, floating specks`

### 71. `cardart_card_analyze` — 卡图·解析标记
- 保存为：`art_inbox/cardart_card_analyze.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：解析标记
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a creature bathed in a pale scanning beam that makes its body glow semi-transparent, revealing its hidden organs inside like an x-ray.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

### 72. `cardart_card_brood` — 卡图·催化孵化
- 保存为：`art_inbox/cardart_card_brood.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：催化孵化
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: eggs bursting open as larvae hatch rapidly.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

### 73. `cardart_card_harden` — 卡图·硬化
- 保存为：`art_inbox/cardart_card_harden.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：硬化
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: skin rapidly hardening into thick chitin plates.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

### 74. `cardart_card_mend` — 卡图·组织修复
- 保存为：`art_inbox/cardart_card_mend.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：组织修复
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: glowing tissue knitting a wound closed.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

### 75. `cardart_card_rally` — 卡图·集群信息素
- 保存为：`art_inbox/cardart_card_rally.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：集群信息素
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a swarm of creatures surrounded by drifting pheromone trails, rallying.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

### 76. `cardart_card_strike` — 卡图·撕咬号令
- 保存为：`art_inbox/cardart_card_strike.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：撕咬号令
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a predator lunging forward to bite, motion lines, close-up on jaws.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

### 77. `cardart_card_stun` — 卡图·震慑
- 保存为：`art_inbox/cardart_card_stun.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：震慑
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a monstrous roar shockwave rippling through the air.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

### 78. `cardart_card_toxin` — 卡图·毒雾
- 保存为：`art_inbox/cardart_card_toxin.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：毒雾
- 提示词：

```text
dark biological fantasy illustration, ink outlines with painterly color, muted earthy tones with bioluminescent accents, readable silhouette, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a rolling cloud of green toxic fog over a battlefield.
```

- 反向提示词：`photo, photorealistic, 3d render, gore, text, letters, handwriting, watermark, signature, logo, card frame, border, blurry`

## P3 · 锦上添花

### 79. `icon_fx_droplet` — 特效·液滴
- 保存为：`art_inbox/icon_fx_droplet.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a liquid droplet.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 80. `icon_fx_slash` — 特效·斩击
- 保存为：`art_inbox/icon_fx_slash.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a curved slash streak.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 81. `icon_fx_spark` — 特效·火花
- 保存为：`art_inbox/icon_fx_spark.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a four-pointed spark.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 82. `icon_fx_spore` — 特效·孢子粒
- 保存为：`art_inbox/icon_fx_spore.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a soft round spore particle.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`
