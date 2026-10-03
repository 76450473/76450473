# 开源规范

## 1. 授权（模板中已经写好）

- **代码**：MIT（`LICENSE`）。
- **美术、音频、文本数据**：CC BY-SA 4.0，写在 LICENSE 的附注里。如果用户希望别人能闭源地二次使用这些素材，可以改为 CC BY 4.0，但要先问用户，并记入 DECISIONS.md。
- **字体**：只用 OFL 授权的字体（思源黑体、Noto Sans SC、霞鹜文楷），并在 `art/fonts/` 里附上 OFL.txt。
- **Godot 引擎**：MIT。发布构建时要附带 Godot 的授权声明（游戏内的"关于"界面或者 README 里都可以）。
- **版权持有人**：LICENSE 里默认写"Chimera Epoch contributors"。如果用户想署自己的名字或 ID，问用户之后再改。

## 2. 素材政策

- 每个第三方素材或 AI 生成的素材都要在 `CREDITS.md` 里登记一行：作者、授权、来源，AI 素材还要写明工具和模型。**没有登记的素材不允许入库。**
- 禁止使用：从其他游戏里扒的素材、授权不明的网图、提示词里带在世艺术家名字或商业 IP 的 AI 图。
- 推荐的 CC0 占位素材：Kenney（音效、UI）、OpenGameArt 上标为 CC0 的内容（逐个核对授权）。
- 单个文件超过 10MB，或者美术总量超过 200MB 时，启用 Git LFS（`.gitattributes` 里已经把 png、ogg 等格式标为 binary）。

## 3. 仓库卫生

- 必须提交：`project.godot`、`*.gd`、`*.tscn`、`*.tres`、`*.gdshader`、`*.uid`、`*.import`、`data/`、`docs/`、`export_presets.cfg`（不含凭据）。
- 不要提交：`.godot/`、`build/`、`screenshots/*.png`、`reports/`、`export_credentials.cfg`（`.gitignore` 里已经排除）。
- 提交信息用 conventional commits：`feat:`、`fix:`、`balance:`、`art:`、`docs:`、`test:`、`chore:`。
- 每次提交都应该是可运行的（godot_check 全绿）。大功能拆成多个能独立运行的小提交。

## 4. CI（`.github/workflows/ci.yml`，模板已包含）

导入 → 检查所有脚本 → 单元测试 → 平衡报告 → 主场景冒烟运行。

如果用户的 Godot 版本不是 4.7.2，就改 `GODOT_VERSION`。M8 再加一个导出任务：缓存导出模板，构建 Windows、Linux、Web 包并上传为 artifact。

## 5. 文档（到 M8 时补齐）

- `README.md`：一句话介绍、截图或 GIF、怎么运行、怎么贡献、授权。模板里已有初版。
- `CONTRIBUTING.md`：开发环境、godot_check 的用法、如何添加基因、种族或 Boss（链接到 systems-spec §11 的扩展清单）、提交规范、素材登记规则。
- `CODE_OF_CONDUCT.md`：采用 Contributor Covenant 2.1。
- `CHANGELOG.md`：每个里程碑结束时更新一次。
- `.github/ISSUE_TEMPLATE/`：Bug 报告模板（要求附上种子、版本号和复现步骤）、内容提案模板（新基因或新种族）。

## 6. 发布（每一步都要先问用户）

- **GitHub**：仓库的创建和推送由用户决定。推送前确认远程地址和分支；不推送任何密钥。
- **GitHub Release**：给里程碑打 tag，例如 `v0.2.0-m2`，并附上各平台的构建包。
- **itch.io**：用 butler 上传，需要用户的 API key，必须让用户自己设置成环境变量，不能写进仓库。
- **Web 试玩**：可以放在 GitHub Pages 或 itch.io 上，导出时关闭线程支持。
- **Steam**：需要用户的开发者账号和费用，M9 之后再考虑。

## 7. 社区友好

- 内容全部数据化（data/*.json），这是社区贡献的门槛最低的入口：新基因、新事件、新配方只需要写 JSON 加测试。
- 留好 Mod 接口（M9）：`user://mods/*.json` 和 data 使用同一套格式，用 validate 做校验。
- 新手友好的 issue 标签：`good first issue`，适合"加一个基因"、"加一个事件"这类任务。
