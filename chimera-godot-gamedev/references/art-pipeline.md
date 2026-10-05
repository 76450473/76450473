# 美术协作管线：用户出图 → Claude 导入与适配

Claude 自己不能生成图片，本项目也不调用任何生图 API。分工如下：
- **用户**：在自己的 Codex（桌面版）里装上美术技能 `chimera-art`（按《Codex使用说明.txt》），在一个单独的美术文件夹里说"$chimera-art 开始"。Codex 先出 3 种画风让用户选一次，再做定调批，然后分批出图：每项出候选、自检、预选，生成审核页让用户审，合格的按清单文件名存进 `art_pack/`，最后打包成 `outbox/art_pack.zip`，用户放进游戏文件夹。备用方案是 ChatGPT 网页版项目（《GPT使用说明.txt》）。也可以用其他任何 AI 生图工具。之后补图时，可以再给一个新的 zip，或者直接把图片放进 `art_inbox/`。
- **Claude**：抠图、裁边、缩放、计算挂点、对齐插槽、截图检查。告诉用户哪些图要重做、还缺什么，并给出一段**可以直接粘贴到 Codex 的补图请求**（§7）。

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
| `src/art/art_manifest.gd` | 把 manifest 和游戏数据（基因部件、骨架、生态区、卡牌、Boss）**推导**成完整的资产列表，共 88 项（含 6 个敌方反派骨架）；能输出 Markdown 格式的提示词书 |
| `tools/art_audit.gd` | 每次运行都重新生成五份文件：`docs/ART_TODO.md`（缺失资产 + 提示词）、`docs/ART_PROMPTS.md`（全部资产）、`docs/ART_PROMPTS.txt`（纯文本版，就是《美术资产清单与提示词.txt》第七节，给 ChatGPT 备用方案）、`docs/ART_ASSETS.json`（全部资产的机器可读清单，给 Codex 美术技能）、`docs/ART_REQUEST.txt`（缺失部分的补图请求，用户粘贴到 Codex 里）。加 `-- p1` 只看 P1 缺口；换风格后加 `-- restyle`，补图请求列出全部资产（§8） |
| `tools/unpack_assets.gd` | 用 Godot 的 ZIPReader 解压资产包（不依赖 unzip），也支持文件夹：把图片和 credits.txt 平铺放进 `art_inbox/`；会跳过 `__MACOSX` 目录、隐藏文件，以及内含 SKILL.md 的 zip |
| `scripts/import_assets.sh`（skill 自带） | **一键导入**：自动发现资产包 → 解压 → 导入 → 注册 → 统计缺失 → 全量检查 → 截 5 张图（检查台四页加主场景）→ 把资产包移到 `art_inbox/_packs/`（重名时自动加编号） |
| `scripts/prepare_root.sh`（skill 自带） | 项目根目录里如果有解压后的 skill 文件夹（或其他含 project.godot 的文件夹），给它加 `.gdignore`，并写进 `.gitignore`，避免类名冲突、避免被提交 |
| `tools/import_art.gd` | 把 `art_inbox/` 里的图片处理后放进 `art/`，写 sidecar json，在 CREDITS.md 登记，原图移到 `art_inbox/_done/`；用不了的原图（avif 等格式、损坏）移到 `art_inbox/_failed/` |
| `src/art/art_importer.gd` | 纯图像处理（有测试）：泛洪去背景（透明图直接用 alpha）、羽化、裁边、灰度化（只用于 palette 模式）、单色图标、fit / cover 缩放、计算锚点 |
| `src/art/art_library.gd` | 运行时查找资产。查不到返回 `{}`，调用方据此回退到程序化美术 |
| `src/shaders/part_palette.gdshader` | 彩色立绘（cutout）原样显示，只叠加淡化的基因材质层；palette 模式下把灰度图映射成一套配色（dark→base→light 渐变）：骨架用宿主的种族配色，部件用来源种族的配色再混入 25% 宿主底色（见 visual-system §6）；饱和区域映射为元素强调色；最后叠加基因材质层 |
| `scenes/art_gallery.tscn`、`art_parts.tscn`、`art_images.tscn`、`art_enemies.tscn` | 美术检查台共四页：①我方骨架加挂点十字、各族展示、全部图标；②全部部件，每个部件单独装在一个角色身上；③背景、标题、界面、卡框、卡背、Boss、卡图；④敌方反派骨架（光身和装上基因两排，朝左） |

## 2. 资产类型与模式

| 类别 | id 例子 | 存放位置 | 模式 | 生成背景 | 画布 |
|---|---|---|---|---|---|
| 我方角色立绘 body | `body_biped` | art/bodies/ | cutout | 纯白或透明 | 512×768（竖版 2:3） |
| 敌方反派立绘 | `body_hexapod_enemy` | art/bodies/ | cutout | 纯白或透明 | 576×864 |
| 部件（配饰）part | `part_eye_compound` | art/parts/ | cutout | 纯白或透明 | 256 |
| 战斗背景 | `bg_swamp` | art/bg/ | color | 画面本身 | 1600×900（cover） |
| 图标 | `icon_status_poison` | art/icons/ | mono | 纯黑 | 128 |
| Boss 立绘 | `boss_rotbrood_matriarch` | art/boss/ | cutout | 纯白 | 768 |
| 卡图 | `cardart_card_strike` | art/cards/ | color | 画面本身 | 512×384（cover） |
| UI 与标题 | `card_frame`、`ui_panel`、`title_art` | art/ui/、art/bg/ | cutout 或 color | 见清单 | 见清单 |

**美术方向是二次元 × 仙侠立绘 × 哥特未来的彩色立绘**（visual-system §1）：
- **骨架 = 每族一名成年角色的全身立绘**（我方 5 女 1 男）。敌人用同族的反派立绘（`body_<骨架>_enemy`），画得更大、更凶。没有反派图时，敌人用我方骨架顶上。
- **部件 = 可装配的配饰和身体特征**，保留来源种族的配色。比如虫族的复眼面罩戴在人族剑修身上，一看就知道是虫族基因。这是设计如此。
- 全部是保留原色的 cutout 模式。旧的 palette（灰度 + 运行时上色）模式还能用：把 manifest 里的 `part_mode` / `body_mode` 改成 `palette`。

## 3. 用户的流程（Claude 要用中文向用户解释成这样）

**开局一次性带齐（推荐）**
1. 在 Codex 里用美术技能生产（文件名由 Codex 自动按清单命名），或者用 ChatGPT 项目、其他生图工具按《美术资产清单与提示词.txt》生产，每张按清单里的文件名保存（例如 `part_eye_compound.png`）。
   Windows 要先在资源管理器里打开"显示文件扩展名"，避免存成 `.png.png`。即使存错了，导入工具也能识别。
2. 把所有图片和一个 `credits.txt`（UTF-8 编码，写一行：用的工具或模型，以及授权）放进一个**英文名**的文件夹（例如 `art_pack`），压缩成 zip，zip 本身可以叫 `美术资产包.zip`。zip 里有子文件夹也没关系。
3. 新建一个空文件夹，把 zip 放进去，在这个文件夹里启动 Claude Code，发送提示词。

**之后补图**
- 把 Claude 给的补图请求粘贴到 Codex 里（Codex 只补这些图，审核后生成 `outbox/fix_NN.zip`，并自动更新它的 art_pack），再把新的 zip 放进项目文件夹（或者把图片直接放进 `art_inbox/`），然后说"导入美术"。
- 名字写错也没关系，Claude 会看图帮忙改名。

## 4. Claude 的"导入美术"流程（必须按这个顺序做）

1. **一键导入**：`bash SKILL_DIR/scripts/import_assets.sh <项目>`。
   - 资产包在项目外面时，把路径作为参数传进去：`import_assets.sh <项目> <资产包.zip>`。
   - 新建项目时 `new_project.sh` 会自动调用它。
   - 这一步会完成解压、处理、注册、统计缺失、全量检查，截 5 张图，并把每张图的警告打印出来（警告的含义见 §7）。
   - 5 张图是 `screenshots/art_gallery.png`、`art_parts.png`、`art_images.png`、`art_enemies.png` 和 `main.png`。
2. **处理剩下的图片**，脚本最后会分两类提示：
   - 以 `?` 开头：文件名不认识。**用 Read 逐张打开看**，判断它是哪个资产，在 `art_inbox/` 里 `mv` 改成正确的 id，然后**不带资产包参数**重跑 `import_assets.sh <项目>`（带上参数会重新解压整个包，又把旧文件名带回来）。实在判断不了就问用户。
   - 以 `x` 开头：图片用不了（格式不支持，如 avif、heic、gif、psd；或者文件损坏）。原图已移到 `art_inbox/_failed/`，以后不会重复报。请用户重新导出为 PNG，放进 `art_inbox/` 或新的资产包。
3. （可选）只想预演、不落盘时：`godot --headless --path . --script res://tools/import_art.gd -- --dry`。
4. **逐张看处理结果**：用 Read 打开 `art/...png`，按 §5 的标准检查。
5. **截图检查**：第 1 步已经截好 5 张图（`screenshots/art_gallery.png`、`art_parts.png`、`art_images.png`、`art_enemies.png`、`main.png`）。用 Read 看截图。四页检查台都要看：第 1 页是我方骨架和图标，第 2 页是全部部件，第 3 页是背景、界面、Boss、卡图，第 4 页是敌方反派。最后再对比主场景。
6. **对齐**：部件错位或者大小不对，就按 §6 修改 sidecar json，然后**重新截图**确认，直到通过为止。最简单的方法是重跑 `bash SKILL_DIR/scripts/import_assets.sh <项目>`（不带资产包参数）：没有新图时，它也会重新截 5 张图。只想重截某一页时，用 `bash SKILL_DIR/scripts/screenshot.sh <项目> res://scenes/art_parts.tscn screenshots/art_parts.png`（第 1、3、4 页对应 art_gallery.tscn、art_images.tscn、art_enemies.tscn）。
7. **跑全部检查**：`godot_check.sh`。截图是用来看画面效果的，测试是用来确认没有坏掉的，两者都要做。
8. **重新生成缺失清单**：`godot --headless --path . --script res://tools/art_audit.gd`（同时刷新 ART_TODO.md、ART_PROMPTS.md、ART_PROMPTS.txt、ART_ASSETS.json、ART_REQUEST.txt）。加 `-- p1` 时 ART_TODO.md 和 ART_REQUEST.txt 都只列 P1；`import_assets.sh`、`godot_check.sh` 会不带 p1 重跑它，所以要给用户 P1 补图请求时，最后再跑一次 `-- p1` 再取文件。
9. **汇报**（中文）：
   - 本次导入了哪些（附检查台截图路径）
   - **第一次交来立绘时（通常是定调批）先判断"能不能用"**：看 `screenshots/main.png`（基因实验室，单位身上装着基因器官）和检查台第 2 页，确认器官装在立绘上不打架、缩到棋子大小还认得出种族、画风合世界观（visual-system §1）。不合适就**先停下批量生产**：在补图请求里写清要怎么改（例如"头顶不要帽子，器官要装在那里"），改到合适再让用户在 Codex 里"继续"。
   - **需要重做的**和原因
   - 还缺多少项（P1、P2、P3）
   - **一段补图请求**（§7 的格式），让用户整段复制到 Codex 里：缺失的取 `docs/ART_REQUEST.txt`，再加上要重做的。缺得很多时，建议先补 P1。
   - 用户还在 Codex 里按顺序生产（交来的是定调批、P1 或中途"打包"的一部分）时，不要把几十项缺失都塞进补图请求：补图请求只写**要重做的**；缺失的告诉用户"在 Codex 里说『$chimera-art 继续』接着做就行"，完整的缺失请求留在 `docs/ART_REQUEST.txt`，等主线做完再用。（用 ChatGPT 备用方案的用户是发"继续"加接力码；清单刚变过、他的旧接力码作废时，补图请求要包含全部缺失项。）
   - 用户还一张图都没做过（没有资产包）时，不给补图请求：让用户按《Codex使用说明.txt》装好美术技能，在美术文件夹里发"$chimera-art 开始"。
   - 用 Codex 的用户不用自己复制：Codex 会把补好的图自动更新进它的 art_pack，交来的 fix_NN.zip 只含这次补的图。用 ChatGPT 或其他工具的用户，要提醒他把补好的图也复制进他的 art_pack 覆盖旧图，否则以后整包再交来时旧图会盖回去。导入后发现以前重做过的图又变回了旧图（截图里的老毛病又出现），先问用户是不是把旧的 art_pack 整包又交了一次。
10. 在 PROGRESS.md 的"美术资产"一节更新进度，然后 git commit（提交 `art/`、`CREDITS.md`、`docs/ART_TODO.md`、`docs/ART_PROMPTS.md`、`docs/ART_PROMPTS.txt`、`docs/ART_ASSETS.json`、`docs/ART_REQUEST.txt`；`art_inbox/` 已被 gitignore）。

## 5. 质检：看图与看截图

导入前看原图，以下任何一条不满足就请用户重做：
- 主体对不对，是不是**只有一个物件**。
- 朝向：角色立绘（我方和反派）是 3/4 侧身朝右，Boss 是朝左；部件按提示词写的方向（多数朝右，獠牙、冠饰等有自己的方向）。图标、背景、卡图、界面不要求朝向。
- **角色立绘**：
  - 头顶、肩背、前臂、胸口没被帽子、兜帽、头盔、王冠、披风、翅膀、大领子、宽袖子、手持物挡住（基因器官要装在那里，visual-system §1）；
  - 一眼是成年人（不能有低龄感），服装性感但不裸露；
  - 脸和眼睛好看，手指和四肢没有画崩；
  - 全身都在画面里，脚贴近底边；
  - 种族特征一眼可辨（触角、发间的发光小蘑菇、狼耳、晶体、幽魂下摆）。
  - 反派要明显比我方更高大、更凶。
- 部件的连接端在不在对的位置：比如肢体类部件的根部应该在左边、向右伸，冠、晶簇、孢子冠这类应该从底部往上长，尖牙应该从顶部往下垂（每项的提示词里都写明了）。
- **背景是否纯色平底**；主体是否有**闭合的深色描边**。描边有缺口时，背景的泛洪会"漏进"主体里。
- 配色是否符合该种族（race_art 里写的主色调）。palette 模式的资产才要求灰度。
- 和已经入库的资产比，风格是否一致：线宽、明暗层次、细节密度。
- 有没有文字、水印，有没有多余的肢体或碎片。

导入后看截图：
- 部件是否落在正确的挂点上，大小是否合理（显著部件比身体小，长矛、旗帜这类除外）。
- 配饰装在别的种族身上时，是否还能认出它来自哪个种族；材质层（甲壳、菌丝）有没有把脸和服装糊掉。
- 抠图边缘有没有白边或者被啃掉的缺口。
- 缩到棋盘大小（约 50%）时，轮廓还清楚吗？

## 6. 对齐与微调（sidecar json）

每张图旁边都有一个同名的 `.json`。导入工具会写入 `pivot`、`scale`、`size`、`source`、`source_md5`、`credit`。同一张原图（md5 相同）重新导入时保留第一次的 credit；换了新图，或者原来的 credit 是"未注明工具"/"工具待补"，就改用当前 credits.txt 的最后一行。

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
| 彩色面积偏大 | 只在 palette（灰度）模式下出现 | 强调 `strictly grayscale`；默认的 cutout 模式不会有这个警告 |
| 角色看起来太年轻、像小孩 | 二次元模型的常见倾向 | 在 Character 里写明 `adult woman in her mid-twenties, mature face and proportions, tall`；反向提示词里已有 child、loli、chibi |
| 被安全系统拦截 | 服装描述太暴露 | 换成更含蓄的写法（和 Codex 美术技能 prompting.md 第 6 节、GPT项目指令.txt 第八节一致）：`elegant side slit`、`long elegant sleeves`、`modest elegant neckline`、`layered chiffon`，去掉直接描写身体的词 |
| 抠图后主体被啃掉一块 | 描边不闭合 | 加 `thick closed uniform near-black outline around the whole shape` |
| 风格和其他资产差太远 | 工具或者种子不同 | Codex 美术技能会自动用风格参考图和已通过的同类图做参考，补图请求里写清"参照 xxx.png 的画风"即可；ChatGPT：新开对话，先上传 2–3 张已通过的同类图当参考；Midjourney 用 `--sref <第一张满意图的链接>`；SD 固定模型并加 IP-Adapter；即梦等工具上传参考图 |

**向用户要图：补图请求**（用户把它粘贴到 Codex 里，第一行 `$chimera-art` 会调用美术技能，Codex 照着补图，同样自检加用户审核；备用的 ChatGPT 项目也认这个格式）。
- 缺失的部分直接取 `docs/ART_REQUEST.txt`（`art_audit.gd` 每次都会重新生成，就是 `ArtManifest.to_request()` 的输出），格式如下。有瑕疵要重做的按同样格式加进去，写清原因。手写（例如只有重做项）时，**前两行必须原样保留**：第一行 `$chimera-art` 会调用 Codex 美术技能。
```
$chimera-art 【补图请求】来自 Claude（《奇美拉纪元》）
请按美术技能（或 ChatGPT 项目指令）和清单生产下面这些资产，按文件名找对应的项：每项照常自检，再请我审核。文件名必须和下面完全一致。

1. 【13】part_sac.png　毒液吊坠（虫族部件）　—— 重做：背景有阴影，抠图后边缘发灰；要纯白平底背景，不要阴影和地面
2. 【47】body_floater_enemy.png　幽体反派·幽冥女帝（女）　—— 缺失

（共 2 项。全部确认后，把图片按上面的文件名保存，打包成 zip 发给 Claude。）
```
- 【n】是这一项在当前 manifest 里的编号（和 `docs/ART_ASSETS.json`、`docs/ART_PROMPTS.txt`、清单第七节一致）；Codex 美术技能按**文件名**在它的清单里找完整的提示词，所以文件名必须写对。
- 不要让用户写"透明背景"：ChatGPT / Codex 的图像模型常把假的灰白棋盘格画进图里，抠图会失败。一律要纯白平底（图标是纯黑平底）。
- 重做原因要具体，能直接指导改图（"头太小，头部要占身高的七分之一"），并按上表把修改要点写进原因里；需要大改时，在原因后面附上改好的完整英文提示词（Codex 会用它代替清单里的提示词）。想让它参照某张已通过的图，就在原因里写"参照 xxx.png 的画风"（Codex 会把那张图当参考图）。
- 让用户在 Codex 里（项目还是他的 D:\chimera_art）点「新对话」，把这一段整段粘贴进去，不要拆开、不要删第一行。用 ChatGPT 备用方案的用户粘贴到 ChatGPT 项目里。

**ChatGPT 备用方案**（用户说 Codex 出不了图、或者要用网页版 ChatGPT 时）：在游戏文件夹里建 `ChatGPT备用方案/`，复制三个文件进去：`SKILL_DIR/assets/chatgpt_fallback/project_instructions.txt` → `GPT项目指令.txt`，`SKILL_DIR/assets/chatgpt_fallback/guide.txt` → `GPT使用说明.txt`，`docs/ART_PROMPTS.txt` → `ART_PROMPTS.txt`（先跑一次 art_audit 让它是最新的）。告诉用户打开《GPT使用说明.txt》照着做；这个文件夹已被 gitignore。网页版的用户要自己下载改名，补图后也要自己把图复制进他的 art_pack（§4 第 9 步）。

## 8. 新增内容时如何同步美术清单

- 新基因用到**新的部件种类**：先在 `Defs.PART_KINDS` 登记，再在 `CreaturePainter._draw_part` 里画程序化占位，然后在 `art_manifest.json` 的 `parts` 里写 subject、socket、anchor、height、accent，最后在 fusion.json 的 `part_word` 里补上名词。test_data 会检查 PART_KINDS、manifest 条目和 part_word 是否齐全；`_draw_part` 里的占位画法要靠截图（检查台第 2 页）确认。
- 新骨架、新生态区、新卡牌、新 Boss 也同理：在 manifest 对应的节里加一条。
- 加完后跑 `art_audit.gd`。新的缺失项会带着提示词出现在 `docs/ART_TODO.md` 里，也会进 `docs/ART_REQUEST.txt`。
- **清单一变（新增条目、换风格、改提示词），用户那边的旧清单就过时了**，编号也可能整体后移。汇报时告诉用户：把游戏文件夹里的 `docs/ART_ASSETS.json` 复制到他的 Codex 美术文件夹（美术技能会自动换上新清单、按文件名保留进度），然后再贴补图请求。用 ChatGPT 备用方案时：把 `docs/ART_PROMPTS.txt` 上传到 ChatGPT 项目的文件里（项目指令规定：项目里有 ART_PROMPTS.txt 时，逐项提示词和编号以它为准，只按文件名查；以后再更新就删掉旧的再传），以前存的接力码作废，然后再贴补图请求。ART_PROMPTS.txt 开头写着总数、定调批和风格参考图提示词（`style.reference_sheet`）。
- **换风格时**还要同步改 `style.reference_sheet`（风格参考图提示词），然后运行 `godot --headless --path . --script res://tools/art_audit.gd -- restyle`：这时 `docs/ART_REQUEST.txt` 会列出**全部**资产（"重做：风格已更换"，旧图虽然还在也要重做），第三行带"风格已更换"的说明，Codex 会先重新选画风、做定调批，再逐项重做。把这一段和 `docs/ART_ASSETS.json`（Codex 用；ChatGPT 备用方案用 ART_PROMPTS.txt）一起交给用户。注意之后任何不带 `restyle` 的 art_audit（包括 `import_assets.sh`、`godot_check.sh` 里自动跑的）都会把这个文件改回只列缺失项，所以要在交给用户之前最后跑一次。
- **改了通用要求但不换风格时**（例如立绘要给基因器官留位置，旧图可能不再合格）：把 manifest 的 `art_version` 加 1，跑 art_audit，把新的 `docs/ART_ASSETS.json` 交给用户放进美术文件夹根目录。Codex 合并时看到更高的版本，会把提示词变了的已通过图改成重画（旧图先留在 art_pack 里，新图通过后覆盖）。

## 9. 授权与入库

- `import_art.gd` 会把 `art_inbox/credits.txt` 的**最后一行**写进 CREDITS.md（每个资产包的 credits.txt 会追加成新的一行；新包没带 credits.txt 时沿用上一行）。从来没有 credits.txt 时写"未注明工具"，编码不对时写"工具待补"；`import_assets.sh` 会打出 `!!` 提示，**这时要提醒用户补上**，补好后把那些原图从 `_done/` 移回 `art_inbox/` 重新导入。
- AI 生成图片的授权以工具的服务条款为准。提醒用户确认自己的订阅允许商用或开源分发。
- 入库的是 `art/` 里处理后的文件，原图（`art_inbox/`）不进 git。
- 素材默认采用 CC BY-SA 4.0（见 open-source.md）。
