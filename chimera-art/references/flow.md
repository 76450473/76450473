# 流程细节

## 继续

按顺序检查 `state/progress.json`，做第一件适用的事：

1. 根目录有新的 `ART_ASSETS.json`，或者本技能 `assets/assets.json` 的 `version` 比 `state/assets.json` 的大（没有 `version` 算 1，说明技能升级了）→ 先「换清单」。
2. `pending_ref_call` 不为空 → 上次带参考图的调用没回来（多半卡住、用户点了停止）：记 `refs_broken: true`（写上日期），清空 `pending_ref_call`，这一项改成不带参考图重出。
3. 审核页已经出了、用户还没贴回审核结果（`review.items` 里的项都是 `review` 状态）→ 提醒他审完这一批再继续，停下。
4. `review` 里有一批出图做到一半 → 把这批剩下的做完，出审核页。
5. 有没做完的补图任务 `fix_job` → 接着做补图。
6. 否则按 `phase` 往下做：`style` 选画风、`anchor` 定调批、`bulk` 下一批、`done` 告诉他全部完成。

## 选画风

先读 game.md，再用 `reference_sheet` 出 3 张风格参考图（六个种族角色同框），提示词按 prompting.md 第 1、2 节拼，再各加一个方向：
- 第一次选画风：用 prompting.md 第 3 节的 A / B / C。
- 补图请求写着"风格已更换"之后：新的 `reference_sheet` 已经代表新风格，不要再用 A / B / C，改用中性的三个变化：A `Keep exactly this style.`、B `Same style, more delicate and detailed rendering.`、C `Same style, stronger contrast and richer colors.`
存为 `style/style_A.png` 等，出审核页（style 模式），等用户选。汇报时用一句话告诉用户：这一步只选画风（线条、上色、整体气质），正式立绘会按清单画，头顶、肩背、前臂、胸口都留给游戏里的基因器官。选中后：方向句存 `style.clause`、意见译成英文存 `style.note_en`（换风格时先清空旧的），选中的图复制成 `style/style_ref.png`，`phase` 改成 `anchor`。

## 定调批

按 `anchor_batch` 的顺序做这 7 项（出图、自检、预选同「批量」），出审核页，等审核结果。要重画的继续出，直到 7 项都通过。
全部通过后：按「打包」打一次 `outbox/art_pack.zip`，`phase` 改成 `bulk`，然后**停下**，告诉用户："画风定下来了。art_pack.zip 可以先交给 Claude 看看游戏里的效果；满意了发 `$chimera-art 继续`，我开始批量生产。"

## 批量

1. 选这一批：先放 `redo` 的项，再按编号放 `todo` 的项，凑够 8 项左右。**开始出图前**就把这批的 `id`（如 "第3批"）和编号写进 `review`，保存。
2. 每一项：按 prompting.md 拼提示词、带参考图；出候选（`body_`、`boss_`、`title_` 出 2 张，其他 1 张）；每张马上复制到 `candidates/<id>__v<k>.png`；按 selfcheck.md 自检，不合格针对问题改一句再出（同一项最多多出 2 张）；选出首选；状态改成 `review`，保存。
3. 本对话出图满约 12 次就先停下（见 SKILL.md 红线），下次"继续"接着做这批。
4. 这批都出完 → 写 `state/review_data.js`（review.md），告诉用户审核页路径，等他贴回审核结果。
5. 应用审核结果（review.md）后：有没做完的 `fix_job` 先做补图；否则开下一批。全部通过时 `phase` 改成 `done`，打包，告诉用户"美术全部完成"。

## 打包

`art_pack/` 里要有 `credits.txt`（UTF-8 一行：`Codex 内置图像生成（ChatGPT 订阅）`）。只把 `art_pack/` 里平铺的文件压进 `outbox/art_pack.zip`（命令见 workspace.md）。告诉用户 zip 的完整路径：
- 第一次交给 Claude：放进游戏文件夹，按《提示词.txt》第七步说。
- 以后再交：放进同一个游戏文件夹，按《提示词.txt》"补图"一节对 Claude 说"导入美术"。

## 补图

收到补图请求时：
1. 根目录有新的 `ART_ASSETS.json` → 先「换清单」。请求里有文件名在清单里找不到 → 请用户把 Claude 给的 ART_ASSETS.json 放进这个文件夹，停下。
2. 有一批审核页还没审（「继续」第 3 条）→ 先把补图任务存好（下一步），告诉用户"补图请求我记下了，请先把第 N 批审完发给我，之后我先做补图"，停下。
3. 存补图任务：`fix_job = {"no": fix+1, "ids": [...], "reasons": {id: 原因}, "prompts": {}, "restyle": false}`；"重做"的项状态改 `redo`（旧图先留在 art_pack），"缺失"的改 `todo`。原因后面附了完整英文提示词的，存进 `prompts`，重画时用它**代替**清单里的提示词；没附的把原因译成英文加在末尾。原因里写了"参照 xxx.png"的，把 `art_pack` 里那张图的绝对路径加进参考图（总数最多 2 张）。
4. 写着"风格已更换"：`restyle` 记为 true；旧的 `style/style_ref.png` 改名为 `style_ref_old.png`；所有已通过的项改成 `redo`（旧图留在 art_pack 里，但**不再当参考图**）；`phase` 改成 `style`，按「选画风」重新选、「定调批」重新定调（定调批里通过的项算补图已完成）。
5. 按「批量」的规则一批批做 `fix_job.ids` 里的项（每批约 8 项，出审核页，等审核结果）。
6. 都处理完（通过或跳过）后：新图覆盖进 `art_pack/`，把这次通过的图加 credits.txt 压进 `outbox/fix_NN.zip`（NN = `fix_job.no`，两位数），`fix` 改成这个编号，清空 `fix_job`。告诉用户 zip 的完整路径、跳过了哪些和原因，并说"Codex 已经自动更新了 art_pack，不用你动"。然后回到原来的批量生产（等他发"继续"）。

## 换清单

新清单 = 工作区根目录的 `ART_ASSETS.json`（Claude 给的），或者技能升级后自带的 `assets/assets.json`（`version` 更大时，不要移动它）。下面的 `version` 没有时都算 1。

1. 新清单的 `version` 比 `state/assets.json` 的小：不用它，把它移到 `state/merged/`，告诉用户"这份清单是旧版，请让 Claude 重新生成"，然后照常往下做。
2. 旧的 `state/assets.json` 复制到 `state/merged/assets_<日期>.json`，再用新清单**整个替换** `state/assets.json`（`version`、`total`、`anchor_batch`、`reference_sheet`、`items` 全部换新）。
3. 按 `id` 合并 progress.json：已有的项保留状态，`n` 更新成新编号；新增的项记 `todo`；清单里没有了的项从 items 里删掉。
4. `version` 变大时还要：状态是 `approved` 或 `review` 的项，新旧 `prompt` 不一样的改成 `redo`（旧图留在 art_pack，新图通过后才覆盖）；有待审的批次就把它的 `review.id` 加进 `review_void`、清空 `review`，把 `state/review_data.js` 改成没有图的一页（title 写"这一批已作废（清单升级了），等新的审核页"），告诉用户不用再审；`phase` 是 `style` 就把已出的风格图作废，用新的 `reference_sheet` 重新出；`phase` 是 `done` 而有项改成了 `redo` 就改回 `bulk`。
5. 根目录的 `ART_ASSETS.json` 移到 `state/merged/ART_ASSETS_<日期>.json`（避免重复合并）。
6. 告诉用户新增了哪些、删掉了哪些；版本变大时再说"清单升级到第 N 版，有 x 张图的要求变了，会按新要求重画（旧图先留着，新图通过后才替换）"。

## 换风格（用户自己要求）

确认后：旧 `style_ref.png` 改名 `style_ref_old.png`，所有已通过的项改成 `redo`，`phase` 改成 `style`，用 A / B / C 重新选画风。重做完的图一样存进 art_pack 覆盖旧图。
