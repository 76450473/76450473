# 美术协作管线：用户生成图片 → Claude 导入与适配

Claude 自己不能生成图片。分工如下：
- **用户**：按提示词用 AI 生图工具出图。通常是**开局就把全部图片打包成一个 zip 资产包**，放进项目文件夹；之后补图时，可以再给一个新的 zip，或者直接把图片放进 `art_inbox/`。
- **Claude**：抠图、裁边、灰度化、缩放、计算挂点、对齐插槽、截图检查。告诉用户哪些图要重做、还缺什么，并给出提示词。

缺失的资产永远回退到程序化占位美术，所以**任何时候游戏都能运行**，美术可以一张一张地补。

## 目录
1. 组成部分
2. 资产类型与模式
3. 用户的流程
4. Claude 的"导入美术"流程（必须按这个顺序做）
5. 质检：看图与看截图
6. 对齐与微调（sidecar json）
7. 什么时候要求用户重做，怎么改提示词
8. 新增内容时如何同步美术清单
9. 授权与入库

---

## 1. 组成部分

| 文件 | 作用 |
|---|---|
| `data/art_manifest.json` | 唯一的真相源。定义风格锁定提示词、各族形状语言、每个部件、骨架、图标和背景的主体描述、挂点、锚点、显示高度 |
| `src/art/art_manifest.gd` | 把 manifest 和游戏数据（基因部件、骨架、生态区、卡牌、Boss）**推导**成完整的资产列表，共 82 项；能输出 Markdown 格式的提示词书 |
| `tools/art_audit.gd` | 列出缺失资产，写入 `docs/ART_TODO.md`。加 `-- full` 参数写出全部资产的 `docs/ART_PROMPTS.md`；加 `-- txt` 写出纯文本版 `docs/ART_PROMPTS.txt` |
| `tools/unpack_assets.gd` | 用 Godot 的 ZIPReader 解压资产包（不依赖 unzip），也支持文件夹：把图片和 credits.txt 平铺放进 `art_inbox/`；会跳过 `__MACOSX` 目录、隐藏文件，以及内含 SKILL.md 的 zip |
| `scripts/import_assets.sh`（skill 自带） | **一键导入**：自动发现资产包 → 解压 → 导入 → 注册 → 统计缺失 → 全量检查 → 截 4 张图（检查台三页加主场景）→ 把资产包移到 `art_inbox/_packs/`（重名时自动加编号） |
| `scripts/prepare_root.sh`（skill 自带） | 项目根目录里如果有解压后的 skill 文件夹（或其他含 project.godot 的文件夹），给它加 `.gdignore`，并写进 `.gitignore`，避免类名冲突、避免被提交 |
| `tools/import_art.gd` | 把 `art_inbox/` 里的图片处理后放进 `art/`，写 sidecar json，在 CREDITS.md 登记，原图移到 `art_inbox/_done/` |
| `src/art/art_importer.gd` | 纯图像处理（有测试）：泛洪去背景、羽化、裁边、灰度化（保留饱和的发光色）、单色图标、fit / cover 缩放、计算锚点 |
| `src/art/art_library.gd` | 运行时查找资产。查不到返回 `{}`，调用方据此回退到程序化美术 |
| `src/shaders/part_palette.gdshader` | 把灰度图映射成一套配色（dark→base→light 渐变）：骨架用宿主的种族配色，部件用来源种族的配色再混入 25% 宿主底色（见 visual-system §6）；饱和区域映射为元素强调色；最后叠加基因材质层 |
| `scenes/art_gallery.tscn`、`art_parts.tscn`、`art_images.tscn` | 美术检查台共三页：①骨架加挂点十字、各族展示、全部图标；②全部部件，每个部件单独装在一只生物身上；③背景、标题、界面、卡框、卡背、Boss、卡图 |

## 2. 资产类型与模式

| 类别 | id 例子 | 存放位置 | 模式 | 生成背景 | 画布 |
|---|---|---|---|---|---|
| 骨架 body | `body_biped` | art/bodies/ | palette | 纯白 | 512 |
| 部件 part | `part_eye_compound` | art/parts/ | palette | 纯白 | 256 |
| 战斗背景 | `bg_swamp` | art/bg/ | color | 画面本身 | 1600×900（cover） |
| 图标 | `icon_status_poison` | art/icons/ | mono | 纯黑 | 128 |
| Boss 立绘 | `boss_rotbrood_matriarch` | art/boss/ | cutout | 纯白 | 768 |
| 卡图 | `cardart_card_strike` | art/cards/ | color | 画面本身 | 512×384（cover） |
| UI 与标题 | `card_frame`、`ui_panel`、`title_art` | art/ui/、art/bg/ | cutout 或 color | 见清单 | 见清单 |

**palette（灰度上色）模式是"跨种族拼接仍然协调"的关键。** 部件只画明暗，运行时再上色：
- **骨架**用宿主种族的配色。
- **部件**用它来源种族的颜色，再混入 25% 的宿主底色。比如虫族的复眼长在人族身上，仍然认得出是虫族的东西，但颜色和身体协调。这是设计如此，不是 bug（见 visual-system §6）。
- 图中鲜绿（或者任何高饱和）的区域会被当作发光处，映射为该基因的元素色（毒是绿、易伤是紫……）。

## 3. 用户的流程（Claude 要用中文向用户解释成这样）

**开局一次性带齐（推荐）**
1. 按《美术资产清单与提示词.txt》生成图片，每张按清单里的文件名保存（例如 `part_eye_compound.png`）。
   Windows 要先在资源管理器里打开"显示文件扩展名"，避免存成 `.png.png`。即使存错了，导入工具也能识别。
2. 把所有图片和一个 `credits.txt`（UTF-8 编码，写一行：用的工具或模型，以及授权）放进一个**英文名**的文件夹（例如 `art_pack`），压缩成 zip，zip 本身可以叫 `美术资产包.zip`。zip 里有子文件夹也没关系。
3. 新建一个空文件夹，把 zip 放进去，在这个文件夹里启动 Claude Code，发送提示词。

**之后补图**
- 再给一个新的 zip，或者直接把图片放进 `art_inbox/`，然后说"导入美术"。
- 名字写错也没关系，Claude 会看图帮忙改名。

## 4. Claude 的"导入美术"流程（必须按这个顺序做）

1. **一键导入**：`bash SKILL_DIR/scripts/import_assets.sh <项目>`。
   - 资产包在项目外面时，把路径作为参数传进去：`import_assets.sh <项目> <资产包.zip>`。
   - 新建项目时 `new_project.sh` 会自动调用它。
   - 这一步会完成解压、处理、注册、统计缺失、全量检查，截 4 张图，并把每张图的警告打印出来（警告的含义见 §7）。
   - 4 张图是 `screenshots/art_gallery.png`、`art_parts.png`、`art_images.png` 和 `main.png`。
2. **处理剩下的图片**，脚本最后会分两类提示：
   - 以 `?` 开头：文件名不认识。**用 Read 逐张打开看**，判断它是哪个资产，在 `art_inbox/` 里 `mv` 改成正确的 id，然后**不带资产包参数**重跑 `import_assets.sh <项目>`（带上参数会重新解压整个包，又把旧文件名带回来）。实在判断不了就问用户。
   - 以 `x` 开头：文件名没问题，但图片读不出来（可能损坏，或者是 avif、heic 这类格式）。请用户重新导出为 PNG。
3. （可选）只想预演、不落盘时：`godot --headless --path . --script res://tools/import_art.gd -- --dry`。
4. **逐张看处理结果**：用 Read 打开 `art/...png`，按 §5 的标准检查。
5. **截图检查**：第 1 步已经截好 4 张图（`screenshots/art_gallery.png`、`art_parts.png`、`art_images.png`、`main.png`）。用 Read 看截图。三页检查台都要看：第 1 页是骨架和图标，第 2 页是全部部件，第 3 页是背景、界面、Boss、卡图。最后再对比主场景。
6. **对齐**：部件错位或者大小不对，就按 §6 修改 sidecar json，然后**重新截图**确认，直到通过为止。最简单的方法是重跑 `bash SKILL_DIR/scripts/import_assets.sh <项目>`（不带资产包参数）：没有新图时，它也会重新截 4 张图。只想重截某一页时，用 `bash SKILL_DIR/scripts/screenshot.sh <项目> res://scenes/art_parts.tscn screenshots/art_parts.png`（第 1、3 页对应 art_gallery.tscn、art_images.tscn）。
7. **跑全部检查**：`godot_check.sh`。截图是用来看画面效果的，测试是用来确认没有坏掉的，两者都要做。
8. **重新生成缺失清单**：`godot --headless --path . --script res://tools/art_audit.gd`。
9. **汇报**（中文）：
   - 本次导入了哪些（附检查台截图路径）
   - **需要重做的**（原因加修改后的提示词）
   - 还缺的 P1 资产，列前 5–10 项，附上 `docs/ART_TODO.md` 的位置
   - 下一批建议生成什么
10. 在 PROGRESS.md 的"美术资产"一节更新进度，然后 git commit（提交 `art/`、`CREDITS.md`、`docs/ART_TODO.md`；`art_inbox/` 已被 gitignore）。

## 5. 质检：看图与看截图

导入前看原图，以下任何一条不满足就请用户重做：
- 主体对不对，是不是**只有一个物件**。
- 朝向：部件和骨架是侧视朝右，Boss 是朝左。图标、背景、卡图、界面不要求朝向。
- 部件的连接端在不在对的位置：比如肢体类部件的根部应该在左边、向右伸，冠、晶簇、孢子冠这类应该从底部往上长，尖牙应该从顶部往下垂（每项的提示词里都写明了）。
- **背景是否纯色平底**；主体是否有**闭合的深色描边**。描边有缺口时，背景的泛洪会"漏进"主体里。
- palette 类资产是否是**灰度**的，只有发光处是鲜艳颜色。
- 和已经入库的资产比，风格是否一致：线宽、明暗层次、细节密度。
- 有没有文字、水印，有没有多余的肢体或碎片。

导入后看截图：
- 部件是否落在正确的挂点上，大小是否合理（显著部件比身体小，长矛、旗帜这类除外）。
- 上色后是否还能认出种族来源；材质层（甲壳、菌丝）有没有把细节糊掉。
- 抠图边缘有没有白边或者被啃掉的缺口。
- 缩到棋盘大小（约 50%）时，轮廓还清楚吗？

## 6. 对齐与微调（sidecar json）

每张图旁边都有一个同名的 `.json`。导入工具会写入 `pivot`、`scale`、`size`、`source`、`credit`。

**如何重新导入**：把原图从 `art_inbox/_done/<文件名>` 移回 `art_inbox/`，然后重跑 `import_assets.sh`。

**以下键是手调的，重新导入时会保留**：
- `offset: [dx, dy]`：相对挂点的偏移，单位是生物本地像素（身高约 150 像素）。
- `scale_mult`：在自动计算出的大小基础上再乘的倍数。
- `rotation`：旋转角度，单位是度。
- `sockets`：**只用于骨架**。覆盖该骨架各挂点的坐标（head、eye、back、core、limb、torso、head_r）。比如用户画的人头比默认的高，就改 `"head": [2, -124]`。

调整方法：
- 在检查台截图上找到对应的粉色十字。
- 估算要偏移多少：截图里的生物显示比例是 1.15 × scale。
- 改 json 后重新截图，通常 1–3 轮就能对齐。
- **不要改代码去适配某一张图**，所有调整都写在 json 里。

## 7. 什么时候要求用户重做，怎么改提示词

| 导入警告或现象 | 原因 | 给用户的修改建议 |
|---|---|---|
| 几乎没有去掉背景 | 背景不是纯色，或者有渐变、纹理 | 在提示词里加 `plain flat pure white background, no gradient, no texture`；工具有"背景"选项就选纯色 |
| 几乎整张图都被当成了背景 | 主体太小，或者和背景太接近 | 加 `filling most of the frame`；让主体颜色更深，描边更粗 |
| 主体只有 N 像素，放大后会糊 | 主体在原图里占比太小 | 同上，或者用 1024 以上的分辨率生成 |
| 彩色面积偏大 | 生成了彩色图 | 强调 `monochrome grayscale, strictly grayscale`。也可以把这一项改成保留原色（在 manifest 的 parts 或 bodies 对应条目里加 `"mode": "cutout"`，然后按 §6 的方法重新导入），但这样就失去了按种族自动上色的能力，必须先征得用户同意 |
| 抠图后主体被啃掉一块 | 描边不闭合 | 加 `thick closed uniform near-black outline around the whole shape` |
| 风格和其他资产差太远 | 工具或者种子不同 | Midjourney 用 `--sref <第一张满意图的链接>`；SD 固定模型并加 IP-Adapter；即梦等工具上传参考图 |

给用户的重做建议要写成**完整可复制的新提示词**：在原提示词的基础上直接改好，不要只说"改一下背景"。

## 8. 新增内容时如何同步美术清单

- 新基因用到**新的部件种类**：先在 `Defs.PART_KINDS` 登记，再在 `CreaturePainter._draw_part` 里画程序化占位，然后在 `art_manifest.json` 的 `parts` 里写 subject、socket、anchor、height、accent，最后在 fusion.json 的 `part_word` 里补上名词。test_data 会检查 PART_KINDS、manifest 条目和 part_word 是否齐全；`_draw_part` 里的占位画法要靠截图（检查台第 2 页）确认。
- 新骨架、新生态区、新卡牌、新 Boss 也同理：在 manifest 对应的节里加一条。
- 加完后跑 `art_audit.gd`。新的缺失项会带着提示词出现在 `docs/ART_TODO.md` 里，告诉用户"新增了 X，需要一张图，提示词在 TODO 第 N 项"。

## 9. 授权与入库

- `import_art.gd` 会把 credits.txt 里的那一行写进 CREDITS.md。没有 credits.txt 时会写"未注明工具"，**这时要提醒用户补上**。
- AI 生成图片的授权以工具的服务条款为准。提醒用户确认自己的订阅允许商用或开源分发。
- 入库的是 `art/` 里处理后的文件，原图（`art_inbox/`）不进 git。
- 素材默认采用 CC BY-SA 4.0（见 open-source.md）。
