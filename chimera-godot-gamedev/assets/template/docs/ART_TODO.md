# 缺失的美术资产（88 项）

进度：P1 0/42　P2 0/42　P3 0/4

怎么用：
1. 推荐用 ChatGPT（网页版或桌面版）的"项目"批量生产：按《GPT使用说明.txt》设置一次，GPT 会逐项生成、先自检，再请你确认。
   也可以用任意 AI 生图工具（Midjourney / Stable Diffusion / 即梦 / 通义万相 …）复制下面的提示词生成：
   Midjourney 建议用二次元模型（--niji 6），末尾加 `--ar 比例 --no 反向提示词`；后续都加 `--sref 第一张满意图的链接`，保持风格统一。
   没有反向提示词栏的工具：在提示词末尾加 `Avoid: 反向提示词`。即梦、通义万相、可灵请关闭"智能扩写/提示词优化"。
2. 每张图按「保存为」的文件名保存（png/jpg/webp 都行，名字对了最省事），打包成 zip 放进游戏文件夹，或者直接放进项目的 `art_inbox/`。
3. 背景要求：角色立绘、部件、Boss 用**纯白平底**（能导出真正的透明 PNG 也行；在 ChatGPT 里别要"透明背景"，它常画出假的灰白棋盘格），图标用**纯黑平底**；主体边缘要清楚，这样才能自动抠图。
   所有角色都是成年人，服装性感但不裸露。
4. 资产包里放一个 credits.txt，写一行：用的工具/模型 + 授权（例如：ChatGPT 图像生成，Plus 订阅）。
5. 对 Claude 说「导入美术」。它会处理、截图检查，并告诉你哪些要重做、还缺什么（附一段可以直接发给 GPT 的补图请求）。
缺的资产不影响游戏运行——会自动用程序化占位美术代替。

## P1 · 先做（M1–M2 需要）

### 1. `body_biped` — 人族本体·剑修少女（女）
- 保存为：`art_inbox/body_biped.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：人族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing character portrait (game standee) of ONE adult character (clearly an adult in their twenties or older, mature proportions), 3/4 view facing right, relaxed elegant standing pose with both arms lowered and empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, sweet and alluring but tasteful fashion like a commercial xianxia game standee (no nudity), no weapons, no props, no extra accessories beyond the described outfit, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a young adult woman of the Human Sect, a graceful cultivator-knight: long black hair in a half-up bun with a white jade hairpin, calm confident gaze, a midnight-blue hanfu-inspired dress with a high side slit, an off-shoulder translucent outer robe with wide flowing sleeves and silver filigree, a fitted gothic corset bodice, thin azure glowing circuit embroidery along the hems, elegant heeled boots. Human Sect motifs: midnight-blue and silver silk, white jade, polished steel filigree, azure glowing circuit embroidery.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, super deformed, nudity, nsfw, nipples, lingerie, see-through clothing, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 2. `body_cluster` — 菌族本体·蘑菇仙子（女）
- 保存为：`art_inbox/body_cluster.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：菌族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing character portrait (game standee) of ONE adult character (clearly an adult in their twenties or older, mature proportions), 3/4 view facing right, relaxed elegant standing pose with both arms lowered and empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, sweet and alluring but tasteful fashion like a commercial xianxia game standee (no nudity), no weapons, no props, no extra accessories beyond the described outfit, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a young adult woman of the Fungal race, a mushroom fairy: a wide soft pale mushroom-cap hat with gently glowing spots, pastel mint-green hair, a sleepy gentle smile, a layered ivory-and-moss-green frilled dress whose skirt layers look like mushroom gills, an off-shoulder neckline, sheer puffed sleeves, faint bioluminescent spores drifting around the hem. Fungal race motifs: ivory and moss-green fabrics, soft mushroom-cap textures with gently glowing spots, delicate mycelium lace, pastel bioluminescence.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, super deformed, nudity, nsfw, nipples, lingerie, see-through clothing, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 3. `body_cluster_enemy` — 菌族反派·腐巫女（女）
- 保存为：`art_inbox/body_cluster_enemy.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：敌方菌族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing villain character portrait (game standee) of ONE adult antagonist that clearly outclasses the heroes: larger, more imposing and more powerful-looking, a sharp aggressive silhouette, a dark sinister palette with ominous glows, an intimidating stance, 3/4 view facing right, both arms lowered with empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, no weapons, no props, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a sinister adult rot witch: a cracked dark mushroom-cap crown, long dark-green hair, glowing sickly-green eyes and a wicked smile, a decayed black-and-olive gown overgrown with dark fungal frills and dripping spores, rot creeping up one arm, much taller than a normal woman. Fungal race motifs: ivory and moss-green fabrics, soft mushroom-cap textures with gently glowing spots, delicate mycelium lace, pastel bioluminescence.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, cute, super deformed, nudity, nsfw, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 4. `body_hexapod` — 虫族本体·虫后之女（女）
- 保存为：`art_inbox/body_hexapod.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：虫族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing character portrait (game standee) of ONE adult character (clearly an adult in their twenties or older, mature proportions), 3/4 view facing right, relaxed elegant standing pose with both arms lowered and empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, sweet and alluring but tasteful fashion like a commercial xianxia game standee (no nudity), no weapons, no props, no extra accessories beyond the described outfit, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a young adult woman of the Insect race: long wavy wine-red hair with two slender antennae rising from her head, amber eyes, a glossy crimson-and-black chitin-plated gown with gothic black lace, a high-collared fitted bodice and a long skirt with a high slit, sheer black lace sleeves, chitin heels. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, super deformed, nudity, nsfw, nipples, lingerie, see-through clothing, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 5. `body_hexapod_enemy` — 虫族反派·甲虫战王（男）
- 保存为：`art_inbox/body_hexapod_enemy.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：敌方虫族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing villain character portrait (game standee) of ONE adult antagonist that clearly outclasses the heroes: larger, more imposing and more powerful-looking, a sharp aggressive silhouette, a dark sinister palette with ominous glows, an intimidating stance, 3/4 view facing right, both arms lowered with empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, no weapons, no props, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a hulking insect warlord: a massive armored man-insect with four muscular arms, a horned black chitin head carapace that hides his face except for glowing crimson eyes, jagged crimson chitin armor plates, a tattered dark war cape. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, cute, super deformed, nudity, nsfw, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 6. `part_banner` — 背负战旗（人族部件）
- 保存为：`art_inbox/part_banner.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：战旗
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a tall back-mounted war banner: a slim pole standing upright with a long embroidered silk pennant hanging from its top on the left side, the pole's bottom end at the bottom of the image, no person. Human Sect motifs: midnight-blue and silver silk, white jade, polished steel filigree, azure glowing circuit embroidery.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 7. `part_bloom` — 尸花胸饰（菌族部件）
- 保存为：`art_inbox/part_bloom.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：尸花
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single large six-petal corpse-flower corsage seen from the front, deep crimson petals, no stem, no leaves. Fungal race motifs: ivory and moss-green fabrics, soft mushroom-cap textures with gently glowing spots, delicate mycelium lace, pastel bioluminescence. Glowing details: the flower center.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 8. `part_egg_sac` — 卵囊背饰（虫族部件）
- 保存为：`art_inbox/part_egg_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：产卵管
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a back-worn cluster of four glossy pearl-like insect eggs bound in a black lace-and-chitin harness, the bundle alone. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 9. `part_eye_compound` — 复眼面罩（虫族部件）
- 保存为：`art_inbox/part_eye_compound.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：复眼
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a sleek visor of hexagonal amber compound lenses in a slim black chitin frame, seen from the side, like a futuristic insect eyepiece, the visor alone. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents. Glowing details: a small glint at the center of each facet.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 10. `part_mandible` — 巨颚面甲（虫族部件）
- 保存为：`art_inbox/part_mandible.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：巨颚
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a sleek chitin face-guard mask with a pair of curved serrated mandible blades, seen from the side, its hinge at the left edge and the open mandibles pointing to the right, the mask alone. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 11. `part_mycelium_web` — 菌丝披肩（菌族部件）
- 保存为：`art_inbox/part_mycelium_web.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：菌丝网
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a delicate shawl-shaped piece of dense ivory mycelium lace: a roughly round, opaque felted lace mat with fine thread patterns and a few short tufts along its edge, no holes or gaps. Fungal race motifs: ivory and moss-green fabrics, soft mushroom-cap textures with gently glowing spots, delicate mycelium lace, pastel bioluminescence.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 12. `part_plating` — 镶甲束胸（人族部件）
- 保存为：`art_inbox/part_plating.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：镶甲
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: an ornamental armored corset front made of three overlapping polished steel plates with silver filigree and azure light lines, lying flat, the armor piece alone. Human Sect motifs: midnight-blue and silver silk, white jade, polished steel filigree, azure glowing circuit embroidery.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 13. `part_sac` — 毒液吊坠（虫族部件）
- 保存为：`art_inbox/part_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：疫心、毒腺
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a venom vial pendant: one bulbous translucent glass-like sac with veins, held in black chitin filigree, the pendant alone. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents. Glowing details: the small pool of liquid in the lower half of the sac.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 14. `part_sash` — 仪式肩带（人族部件）
- 保存为：`art_inbox/part_sash.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：协同操练
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a diagonal ceremonial silk sash with a white-jade rally badge pinned on it and short silver tassels, lying flat, running from upper left to lower right, the sash alone. Human Sect motifs: midnight-blue and silver silk, white jade, polished steel filigree, azure glowing circuit embroidery.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 15. `part_satchel` — 医者小包（人族部件）
- 保存为：`art_inbox/part_satchel.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：战地包扎
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a small elegant medic pouch of dark leather with silver clasps, a softly glowing azure cross emblem and a short strap stub, the pouch alone. Human Sect motifs: midnight-blue and silver silk, white jade, polished steel filigree, azure glowing circuit embroidery.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 16. `part_shell_plate` — 甲壳鞘翅（虫族部件）
- 保存为：`art_inbox/part_shell_plate.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：甲壳
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a pair of folded glossy crimson chitin wing-cases with gothic lace edges and an iridescent sheen, about twice as wide as tall, the wings alone. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 17. `part_spear` — 仙侠长枪（人族部件）
- 保存为：`art_inbox/part_spear.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：长矛
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a long ornate xianxia spear lying diagonally from lower left to upper right: a slender dark lacquered shaft with silver rings and a red tassel, a leaf-shaped glowing steel blade at the upper right end, the weapon alone with no hand. Human Sect motifs: midnight-blue and silver silk, white jade, polished steel filigree, azure glowing circuit embroidery.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 18. `part_spore_cap` — 孢子菌冠（菌族部件）
- 保存为：`art_inbox/part_spore_cap.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：孢子囊
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: three small mushroom caps with glowing spots sprouting upward from one shared mossy base at the bottom, like a living shoulder ornament. Fungal race motifs: ivory and moss-green fabrics, soft mushroom-cap textures with gently glowing spots, delicate mycelium lace, pastel bioluminescence. Glowing details: the spots on the caps.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 19. `part_spray_nozzle` — 喷射护腕（虫族部件）
- 保存为：`art_inbox/part_spray_nozzle.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：喷射器官
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a sleek chitin wrist-mounted sprayer gauntlet lying horizontally, its cuff at the left edge and a fine nozzle pointing right, one drop of liquid at the tip, the gauntlet alone. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents. Glowing details: the dripping liquid.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 20. `part_tendril` — 菌须（菌族部件）
- 保存为：`art_inbox/part_tendril.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：腐触
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single elegant pale fungal tendril growing horizontally to the right from a soft rounded base at the left edge, gently curling, tapering to a fine hooked tip, about twice as long as it is tall. Fungal race motifs: ivory and moss-green fabrics, soft mushroom-cap textures with gently glowing spots, delicate mycelium lace, pastel bioluminescence.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 21. `part_volatile_sac` — 爆裂晶囊（虫族部件）
- 保存为：`art_inbox/part_volatile_sac.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：死亡爆裂
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: an unstable glowing explosive gland orb held in a cracked chitin cage, the orb alone. Insect race motifs: glossy crimson-and-black chitin plates, wine-red silk, gothic black lace, iridescent translucent membranes, amber lens accents. Glowing details: the cracks and the core.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 22. `bg_swamp` — 战斗背景·腐沼
- 保存为：`art_inbox/bg_swamp.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：腐沼
- 提示词：

```text
anime game background art blended with Chinese xianxia landscape painting, gothic-futurist fantasy, highly detailed, atmospheric lighting and depth, horizon in the upper third, wide calm flat empty ground band across the middle and lower half left open for gameplay, darker and lower in contrast in the center, no characters, no creatures, no text, no UI, no border. Scene: a corrupted spirit marsh at dusk: ruined gothic pagodas half sunk in murky water, twisted dead trees hung with moss, giant glowing toxic-green fungi, floating talisman lanterns, sickly green mist.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, card frame, border, characters, people, creatures, animals, monsters, UI`

### 23. `icon_energy` — 能量
- 保存为：`art_inbox/icon_energy.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a round nucleus orb with a small orbit ring.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 24. `icon_map_battle` — 地图·战斗
- 保存为：`art_inbox/icon_map_battle.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: two crossed claws.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 25. `icon_map_boss` — 地图·Boss
- 保存为：`art_inbox/icon_map_boss.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a jagged crown.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 26. `icon_map_elite` — 地图·精英
- 保存为：`art_inbox/icon_map_elite.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a horned beast skull.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 27. `icon_map_event` — 地图·事件
- 保存为：`art_inbox/icon_map_event.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a question mark made of vines.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 28. `icon_map_habitat` — 地图·栖息地
- 保存为：`art_inbox/icon_map_habitat.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a nest with eggs.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 29. `icon_map_market` — 地图·黑市
- 保存为：`art_inbox/icon_map_market.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a balance scale.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 30. `icon_map_mutation` — 地图·异变池
- 保存为：`art_inbox/icon_map_mutation.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a bubbling cauldron.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 31. `icon_map_ruin` — 地图·遗迹融合台
- 保存为：`art_inbox/icon_map_ruin.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a DNA double helix over an altar.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 32. `icon_stat_armor` — 数值·护甲
- 保存为：`art_inbox/icon_stat_armor.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a chitin shield plate.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 33. `icon_stat_atk` — 数值·攻击
- 保存为：`art_inbox/icon_stat_atk.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a single curved fang.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 34. `icon_stat_hp` — 数值·生命
- 保存为：`art_inbox/icon_stat_hp.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: an anatomical heart.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 35. `icon_stat_spd` — 数值·速度
- 保存为：`art_inbox/icon_stat_spd.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: an insect wing.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 36. `icon_status_infect` — 状态·感染
- 保存为：`art_inbox/icon_status_infect.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a cluster of five round spores.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 37. `icon_status_poison` — 状态·毒
- 保存为：`art_inbox/icon_status_poison.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a single venom droplet.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 38. `icon_status_regen` — 状态·再生
- 保存为：`art_inbox/icon_status_regen.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a rounded plus cross made of living tissue.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 39. `icon_status_stun` — 状态·眩晕
- 保存为：`art_inbox/icon_status_stun.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a spinning four-pointed star with motion arcs.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 40. `icon_status_vulnerable` — 状态·易伤
- 保存为：`art_inbox/icon_status_vulnerable.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a cracked broken shield.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 41. `card_back` — 卡背
- 保存为：`art_inbox/card_back.png`　｜　比例 5:7（建议 1024×1434）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
xianxia gothic-futurist game UI element: black lacquer, white jade and silver filigree with subtle gold cloud patterns and faint glowing azure circuit lines, flat front view, no text. full-bleed card back design filling the whole image edge to edge, a symmetric emblem of a DNA double helix entwined with a xianxia cloud-and-sword sigil on deep midnight lacquer with silver filigree, no rounded corners, no table, no shadow.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, characters, creatures, numbers`

### 42. `card_frame` — 卡牌边框
- 保存为：`art_inbox/card_frame.png`　｜　比例 5:7（建议 1024×1434）　｜　背景：纯白　｜　模式：彩色，去背景
- 提示词：

```text
xianxia gothic-futurist game UI element: black lacquer, white jade and silver filigree with subtle gold cloud patterns and faint glowing azure circuit lines, flat front view, no text. an ornate vertical trading card frame of black lacquer, silver filigree and white-jade inlays, a thick dark outline around its outer edge and around each window; one large empty art window in the middle of the card, from about 12% to 62% of the card height so that it covers the exact center of the image, filled with flat pure white; below it a smaller text box filled with light silk-parchment (not white); plain flat pure white background outside the frame.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, characters, creatures, numbers`

## P2 · 其次（M3–M5）

### 43. `body_biped_enemy` — 人族反派·堕魔宗主（男）
- 保存为：`art_inbox/body_biped_enemy.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：敌方人族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing villain character portrait (game standee) of ONE adult antagonist that clearly outclasses the heroes: larger, more imposing and more powerful-looking, a sharp aggressive silhouette, a dark sinister palette with ominous glows, an intimidating stance, 3/4 view facing right, both arms lowered with empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, no weapons, no props, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a towering adult man, a fallen demonic sect master: long white hair, a cracked white-jade half mask, a cruel smile, a black-and-crimson layered robe with spiked gothic pauldrons and a tall collar, glowing red circuit veins across the fabric, a dark aura. Human Sect motifs: midnight-blue and silver silk, white jade, polished steel filigree, azure glowing circuit embroidery.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, cute, super deformed, nudity, nsfw, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 44. `body_construct` — 晶族本体·晶灵机娘（女）
- 保存为：`art_inbox/body_construct.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：晶族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing character portrait (game standee) of ONE adult character (clearly an adult in their twenties or older, mature proportions), 3/4 view facing right, relaxed elegant standing pose with both arms lowered and empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, sweet and alluring but tasteful fashion like a commercial xianxia game standee (no nudity), no weapons, no props, no extra accessories beyond the described outfit, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a young adult woman of the Crystal race, a crystalline android maiden: porcelain skin with faint geometric facet seams, ice-blue crystal hair in a sleek bob, pale cyan eyes with ring-shaped pupils, a white-and-cyan futuristic gothic dress with prism-glass panels, lace trim and a high slit, thin cyan light lines running over the dress, she hovers slightly above the ground and her lower legs turn into faceted crystal. Crystal race motifs: faceted ice-blue crystal, porcelain-white panels, prismatic glass, cyan glowing light lines.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, super deformed, nudity, nsfw, nipples, lingerie, see-through clothing, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 45. `body_construct_enemy` — 晶族反派·晶甲巨像（男）
- 保存为：`art_inbox/body_construct_enemy.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：敌方晶族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing villain character portrait (game standee) of ONE adult antagonist that clearly outclasses the heroes: larger, more imposing and more powerful-looking, a sharp aggressive silhouette, a dark sinister palette with ominous glows, an intimidating stance, 3/4 view facing right, both arms lowered with empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, no weapons, no props, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a crystal juggernaut knight: a massive armored figure of dark corrupted crystal, a faceless prismatic helmet with a single glowing slit, jagged shard pauldrons, cracks leaking cold cyan light. Crystal race motifs: faceted ice-blue crystal, porcelain-white panels, prismatic glass, cyan glowing light lines.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, cute, super deformed, nudity, nsfw, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 46. `body_floater` — 幽体本体·幽灵贵女（女）
- 保存为：`art_inbox/body_floater.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：幽体
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing character portrait (game standee) of ONE adult character (clearly an adult in their twenties or older, mature proportions), 3/4 view facing right, relaxed elegant standing pose with both arms lowered and empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, sweet and alluring but tasteful fashion like a commercial xianxia game standee (no nudity), no weapons, no props, no extra accessories beyond the described outfit, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a young adult woman of the Wraith race, a melancholic ghost lady: long silver hair under a sheer black-violet hood, glowing violet eyes, pale skin, a tattered layered black-violet veil gown with a deep but tasteful neckline, her lower body fading into translucent misty wisps instead of feet so she floats, pale silver chains of light as jewelry. Wraith race motifs: tattered black-violet veils, misty translucent ectoplasm, pale silver ornaments, eerie violet glow.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, super deformed, nudity, nsfw, nipples, lingerie, see-through clothing, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 47. `body_floater_enemy` — 幽体反派·幽冥女帝（女）
- 保存为：`art_inbox/body_floater_enemy.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：敌方幽体
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing villain character portrait (game standee) of ONE adult antagonist that clearly outclasses the heroes: larger, more imposing and more powerful-looking, a sharp aggressive silhouette, a dark sinister palette with ominous glows, an intimidating stance, 3/4 view facing right, both arms lowered with empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, no weapons, no props, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a phantom empress: a towering ghostly queen with a crown of spectral spikes, a beautiful but skeletal pale face, glowing violet eyes, many layers of tattered black veils trailing into dark mist instead of feet, chains of spectral light floating around her. Wraith race motifs: tattered black-violet veils, misty translucent ectoplasm, pale silver ornaments, eerie violet glow.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, cute, super deformed, nudity, nsfw, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 48. `body_quadruped` — 兽族本体·狼族少主（男）
- 保存为：`art_inbox/body_quadruped.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：兽族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing character portrait (game standee) of ONE adult character (clearly an adult in their twenties or older, mature proportions), 3/4 view facing right, relaxed elegant standing pose with both arms lowered and empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, sweet and alluring but tasteful fashion like a commercial xianxia game standee (no nudity), no weapons, no props, no extra accessories beyond the described outfit, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a young adult man of the Beast race, a wild noble wolf-beastman: wolf ears and a bushy silver-grey wolf tail, messy silver-white hair, sharp amber eyes, a confident smirk, tall and athletic, a dark open-collared hanfu-cut combat coat with bone toggles over a fitted black shirt, leather belts, glowing amber tribal tattoos on his forearms, sturdy boots. Beast race motifs: carved bone ornaments, silver-grey fur trim, dark leather, glowing amber tribal tattoos and runes.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, super deformed, nudity, nsfw, nipples, lingerie, see-through clothing, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 49. `body_quadruped_enemy` — 兽族反派·狼魔王（男）
- 保存为：`art_inbox/body_quadruped_enemy.png`　｜　比例 2:3（建议 1024×1536）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：敌方兽族
- 提示词：

```text
high-quality 2D game art in a refined Japanese anime style blended with Chinese xianxia game character illustration (elegant semi-realistic anime faces, delicate detailed eyes, glossy flowing hair strands), gothic-futurist fantasy: ornate lace, filigree and stained-glass motifs fused with sleek sci-fi elements and fine glowing circuit-like embroidery, crisp clean lineart, soft cel shading with painterly gradients and gentle rim light, rich jewel-tone palette, highly detailed costume, a full-body standing villain character portrait (game standee) of ONE adult antagonist that clearly outclasses the heroes: larger, more imposing and more powerful-looking, a sharp aggressive silhouette, a dark sinister palette with ominous glows, an intimidating stance, 3/4 view facing right, both arms lowered with empty hands, the whole figure from head to feet visible and filling most of the frame height, the feet near the bottom edge, no weapons, no props, plain flat pure white background, no ground, no cast shadow, no text, no logo. Character: a monstrous wolf-demon king: a towering half-beast man with a wolf-skull helm, a wild dark mane, glowing red eyes, huge clawed hands, crude bone armor over dark fur, broken chains around his wrists. Beast race motifs: carved bone ornaments, silver-grey fur trim, dark leather, glowing amber tribal tattoos and runes.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, shota, chibi, cute, super deformed, nudity, nsfw, extra fingers, deformed hands, bad anatomy, multiple characters, weapon, props, scene, background details, ground, cast shadow, frame, cropped`

### 50. `part_claw` — 利爪手甲（兽族部件）
- 保存为：`art_inbox/part_claw.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：扑击
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a clawed gauntlet: an ornate bone-and-silver glove with three long curved claws, the cuff at the left edge and the claws pointing to the right, the gauntlet alone. Beast race motifs: carved bone ornaments, silver-grey fur trim, dark leather, glowing amber tribal tattoos and runes.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 51. `part_core_gem` — 共鸣晶核胸针（晶族部件）
- 保存为：`art_inbox/part_core_gem.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：共鸣核
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single hexagonal faceted resonance gem brooch set in silver filigree. Crystal race motifs: faceted ice-blue crystal, porcelain-white panels, prismatic glass, cyan glowing light lines. Glowing details: the small bright core at the gem's center.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 52. `part_crest` — 角冠（兽族部件）
- 保存为：`art_inbox/part_crest.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：狼嚎
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a tiara-like crest of three sharp horn spikes rising upward from one shared ornate bone base at the bottom. Beast race motifs: carved bone ornaments, silver-grey fur trim, dark leather, glowing amber tribal tattoos and runes.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 53. `part_crystal_cluster` — 浮晶簇（晶族部件）
- 保存为：`art_inbox/part_crystal_cluster.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：晶格
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: four floating crystal shards of different heights rising upward from one shared base at the bottom, like a crystal wing ornament. Crystal race motifs: faceted ice-blue crystal, porcelain-white panels, prismatic glass, cyan glowing light lines. Glowing details: a thin glowing line along the center of each shard.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 54. `part_ether_veil` — 灵纱披风（幽体部件）
- 保存为：`art_inbox/part_ether_veil.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：灵体
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a long flowing translucent ghostly veil-cape hanging vertically, its top edge straight with a thin silver clasp line, its lower edge in ragged tatters, the cloth alone with no person. Wraith race motifs: tattered black-violet veils, misty translucent ectoplasm, pale silver ornaments, eerie violet glow.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 55. `part_fang` — 獠牙面具（兽族部件）
- 保存为：`art_inbox/part_fang.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：尖牙
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a fanged lower half-mask of carved white bone with two long curved fangs hanging downward, the mask's top edge at the top of the image, the fang tips pointing down, the mask alone. Beast race motifs: carved bone ornaments, silver-grey fur trim, dark leather, glowing amber tribal tattoos and runes.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 56. `part_fur_mane` — 毛领披肩（兽族部件）
- 保存为：`art_inbox/part_fur_mane.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：厚皮
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a fluffy silver-grey fur collar-mantle rising upward from a straight base line at the bottom, with spiky tufts, seen from the side. Beast race motifs: carved bone ornaments, silver-grey fur trim, dark leather, glowing amber tribal tattoos and runes.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 57. `part_halo` — 幽光冕（幽体部件）
- 保存为：`art_inbox/part_halo.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：恐惧尖啸
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a single thick ring halo of ghostly light with fine silver filigree, seen almost edge-on from the side, a flat wide elliptical ring about twice as wide as it is tall, broken by a clear gap at the bottom so the white background inside the ring connects to the outside. Wraith race motifs: tattered black-violet veils, misty translucent ectoplasm, pale silver ornaments, eerie violet glow. Glowing details: the inner edge of the ring.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 58. `part_prism` — 棱镜发饰（晶族部件）
- 保存为：`art_inbox/part_prism.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：折射棱镜
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: a small floating triangular crystal prism hair ornament standing upright on its flat base, point upward. Crystal race motifs: faceted ice-blue crystal, porcelain-white panels, prismatic glass, cyan glowing light lines. Glowing details: the light at the prism center.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 59. `part_soul_claw` — 噬魂爪（幽体部件）
- 保存为：`art_inbox/part_soul_claw.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：噬魂
- 提示词：

```text
isolated 2D game asset in the same refined Japanese anime × Chinese xianxia gothic-futurist style: a single accessory or body feature for a character, shown on its own (not worn, no person, no hands, no face), 3/4 view facing right, crisp clean lineart, soft cel shading with painterly gradients, ornate gothic filigree mixed with sleek sci-fi panels and faint glowing circuit lines, rich colors, centered and filling most of the frame with a small margin, plain flat pure white background, no ground, no cast shadow, no text, no labels. Subject: three long spectral claw blades of violet ghost light fanning out to the right from one shared ornate silver root at the left edge. Wraith race motifs: tattered black-violet veils, misty translucent ectoplasm, pale silver ornaments, eerie violet glow. Glowing details: the claw tips.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, multiple objects, person, character, face, hands, scene, background details, ground, cast shadow, frame, border, cropped`

### 60. `bg_glacier` — 战斗背景·冰原
- 保存为：`art_inbox/bg_glacier.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：冰原
- 提示词：

```text
anime game background art blended with Chinese xianxia landscape painting, gothic-futurist fantasy, highly detailed, atmospheric lighting and depth, horizon in the upper third, wide calm flat empty ground band across the middle and lower half left open for gameplay, darker and lower in contrast in the center, no characters, no creatures, no text, no UI, no border. Scene: a frozen sky plateau: blue ice cliffs and crystal spires, a ruined white-jade sect gate encrusted with ice, an aurora in a pale cold sky, drifting frost mist.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, card frame, border, characters, people, creatures, animals, monsters, UI`

### 61. `bg_hive` — 战斗背景·巢穴深处
- 保存为：`art_inbox/bg_hive.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：巢穴深处
- 提示词：

```text
anime game background art blended with Chinese xianxia landscape painting, gothic-futurist fantasy, highly detailed, atmospheric lighting and depth, horizon in the upper third, wide calm flat empty ground band across the middle and lower half left open for gameplay, darker and lower in contrast in the center, no characters, no creatures, no text, no UI, no border. Scene: the depths of a colossal insect-hive cathedral: organic resin pillars shaped like gothic arches, honeycomb stained-glass walls glowing amber, faint violet ghost lights, dripping secretions.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, card frame, border, characters, people, creatures, animals, monsters, UI`

### 62. `icon_emblem_beast` — 族徽·兽族
- 保存为：`art_inbox/icon_emblem_beast.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a wolf paw print.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 63. `icon_emblem_crystal` — 族徽·晶族
- 保存为：`art_inbox/icon_emblem_crystal.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a faceted crystal shard.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 64. `icon_emblem_fungal` — 族徽·菌族
- 保存为：`art_inbox/icon_emblem_fungal.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a mushroom.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 65. `icon_emblem_human` — 族徽·人族
- 保存为：`art_inbox/icon_emblem_human.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a raised fist gripping an upright spear.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 66. `icon_emblem_insect` — 族徽·虫族
- 保存为：`art_inbox/icon_emblem_insect.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a beetle seen from above.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 67. `icon_emblem_wraith` — 族徽·幽体
- 保存为：`art_inbox/icon_emblem_wraith.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a hooded ghost mask.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 68. `icon_slot_back` — 插槽·背
- 保存为：`art_inbox/icon_slot_back.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a spine with dorsal spikes.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 69. `icon_slot_core` — 插槽·核
- 保存为：`art_inbox/icon_slot_core.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a cell with a nucleus.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 70. `icon_slot_head` — 插槽·头
- 保存为：`art_inbox/icon_slot_head.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a creature skull seen from the side.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 71. `icon_slot_limb` — 插槽·肢
- 保存为：`art_inbox/icon_slot_limb.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a bent jointed limb.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 72. `icon_slot_skin` — 插槽·皮
- 保存为：`art_inbox/icon_slot_skin.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a patch of scales.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 73. `title_art` — 标题画面主视觉
- 保存为：`art_inbox/title_art.png`　｜　比例 16:9（建议 1920×1080）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. key visual: five race heroines and one wolf-beastman hero (a human cultivator-knight, an insect-race woman, a mushroom fairy, a crystal android maiden, a ghost lady and the wolf beastman) standing together on a cliff above a vast fantastical world, a giant withered tree of life glowing in a starry sky behind them, epic and beautiful, empty sky in the upper third.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

### 74. `ui_button` — 按钮
- 保存为：`art_inbox/ui_button.png`　｜　比例 3:1（建议 1536×512）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
xianxia gothic-futurist game UI element: black lacquer, white jade and silver filigree with subtle gold cloud patterns and faint glowing azure circuit lines, flat front view, no text. a rectangular game button plate of black lacquer with a thin silver-and-jade rim, filling the whole image edge to edge with square corners, empty center.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, characters, creatures, numbers`

### 75. `ui_panel` — 界面面板（九宫格）
- 保存为：`art_inbox/ui_panel.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：画面本身　｜　模式：彩色原样
- 提示词：

```text
xianxia gothic-futurist game UI element: black lacquer, white jade and silver filigree with subtle gold cloud patterns and faint glowing azure circuit lines, flat front view, no text. a square dark lacquer panel filling the whole image edge to edge, an even silver-filigree and jade border of constant width on all four sides, plain empty center, square corners.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, characters, creatures, numbers`

### 76. `boss_rotbrood_matriarch` — 腐巢母皇（Boss 立绘）
- 保存为：`art_inbox/boss_rotbrood_matriarch.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯白　｜　模式：彩色，去背景
- 用在：腐巢母皇
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full body side view facing left, isolated, thick closed dark outline around the whole silhouette, plain flat pure white background, no ground, no cast shadow. Subject: a colossal fungal-insect matriarch queen: an imposing adult queen with a black chitin crown and a rotting mushroom-cap headdress, a massive bloated egg-sac gown studded with dark-shelled eggs, insect legs emerging beneath her skirts, small glowing spore dots, menacing but regal, no loose particles or floating specks.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, chibi, cute, nudity, nsfw, card frame, border, ground, floor, cast shadow, drop shadow, scenery, background details, extra creatures, smoke, clouds, loose particles, floating specks`

### 77. `cardart_card_analyze` — 卡图·解析标记
- 保存为：`art_inbox/cardart_card_analyze.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：解析标记
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a crystal android maiden casting a pale scanning beam from a floating prism; the target glows semi-transparent like an x-ray, revealing hidden organs and gene helices.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

### 78. `cardart_card_brood` — 卡图·催化孵化
- 保存为：`art_inbox/cardart_card_brood.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：催化孵化
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: glossy pearl-like insect eggs bursting open as glowing larvae hatch in a resin nest under stained-glass light.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

### 79. `cardart_card_harden` — 卡图·硬化
- 保存为：`art_inbox/cardart_card_harden.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：硬化
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: an insect-race heroine whose sleeves and gown rapidly sheathe into glossy crimson chitin armor plates with glowing seams.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

### 80. `cardart_card_mend` — 卡图·组织修复
- 保存为：`art_inbox/cardart_card_mend.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：组织修复
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a gentle mushroom-fairy healer closing a glowing wound with soft luminous mycelium threads.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

### 81. `cardart_card_rally` — 卡图·集群信息素
- 保存为：`art_inbox/cardart_card_rally.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：集群信息素
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a human cultivator-knight heroine raising a silk war banner while glowing light trails rally her allies behind her.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

### 82. `cardart_card_strike` — 卡图·撕咬号令
- 保存为：`art_inbox/cardart_card_strike.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：撕咬号令
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a fierce wolf-beastman warrior lunging forward with a glowing claw strike, motion lines, dynamic low angle.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

### 83. `cardart_card_stun` — 卡图·震慑
- 保存为：`art_inbox/cardart_card_stun.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：震慑
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a towering beast-king roaring, a visible shockwave ring rippling through the air and scattering paper talismans.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

### 84. `cardart_card_toxin` — 卡图·毒雾
- 保存为：`art_inbox/cardart_card_toxin.png`　｜　比例 4:3（建议 1024×768）　｜　背景：画面本身　｜　模式：彩色原样
- 用在：毒雾
- 提示词：

```text
refined Japanese anime × Chinese xianxia game illustration, gothic-futurist fantasy, dramatic cinematic lighting, rich jewel tones, highly detailed, all characters are adults, no text, no handwriting, no page or paper border, no watermark. Full-bleed illustration only, no card frame, no border, no title bar, no text box, landscape composition. Subject: a rolling cloud of glowing green toxic fog drifting over a ruined battlefield of gothic pagodas.
```

- 反向提示词：`photo, photorealistic, 3d render, western cartoon, gore, blood, text, letters, watermark, signature, logo, blurry, low quality, jpeg artifacts, child, childlike, loli, nudity, nsfw, card frame, border`

## P3 · 锦上添花

### 85. `icon_fx_droplet` — 特效·液滴
- 保存为：`art_inbox/icon_fx_droplet.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a liquid droplet.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 86. `icon_fx_slash` — 特效·斩击
- 保存为：`art_inbox/icon_fx_slash.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a curved slash streak.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 87. `icon_fx_spark` — 特效·火花
- 保存为：`art_inbox/icon_fx_spark.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a four-pointed spark.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`

### 88. `icon_fx_spore` — 特效·孢子粒
- 保存为：`art_inbox/icon_fx_spore.png`　｜　比例 1:1（建议 1024×1024）　｜　背景：纯黑　｜　模式：白色剪影图标
- 提示词：

```text
flat game UI icon, one bold simple solid white silhouette symbol with a subtle elegant ornamental feel, centered, chunky shapes readable at 32 pixels, plain flat pure black background, no circle or rounded-square tile behind the symbol, no glow, no gradient, no border, no text. Symbol: a soft round spore particle.
```

- 反向提示词：`photo, photorealistic, 3d render, text, letters, words, watermark, signature, logo, circle background, badge, rounded square tile, frame, border, gradient, glow, shading, thin lines, tiny details, blurry`
