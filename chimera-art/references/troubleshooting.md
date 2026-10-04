# 出问题时怎么办

先保存 `state/progress.json`，再用一两句中文告诉用户发生了什么、他要做什么。不要连续重试同一个错误，不要改用 API。

| 现象 | 处理 |
|---|---|
| 工具列表里没有 `image_gen`（或者系统的 imagegen 技能提示要用 CLI / API key） | 不要用 CLI 或 API。告诉用户：①确认 Codex 是用 ChatGPT 账号登录的（不是 API key），订阅不是免费版；②把 Codex 更新到最新版；③点「新对话」再发 `$chimera-art 继续`。还不行就说可以先用备用的 ChatGPT 网页版方案（见《Codex使用说明.txt》最后一节）。 |
| 报错里有 `usage_limit_reached`、`429`、`Too Many Requests` | 额度用完了。马上停，保存进度，告诉用户"出图额度用完了，过几个小时（看 Codex 里显示的恢复时间）回来，点「新对话」发 `$chimera-art 继续`"。不要再试。 |
| 报错里有 `moderation_blocked` | 按 prompting.md 第 6 节改写一次再出；还不行就跳过这一项，告诉用户。 |
| `network error`、超时（一张图几分钟都没结果） | 重试一次，提示词可以精简（保留构图、主体、背景、风格方向）。带参考图的调用卡住，按 prompting.md 第 4 节改成不带参考图。还不行就跳过，告诉用户稍后"继续"。 |
| 出图了，但工具结果里没有文件路径 | 到 `%USERPROFILE%\.codex\generated_images\`（macOS：`~/.codex/generated_images/`）里找最新修改的 png，确认是刚出的那张再复制；找不到就重出这一张。 |
| 聊天里图片显示不出来 / 破图 | 文件一般没问题，照常复制。告诉用户：图显示不出来不要紧，审核页里能看到；要在聊天里看，重启 Codex。 |
| 对话越来越慢、卡 | 保存进度，请用户点「新对话」发 `$chimera-art 继续`。 |
| 用户说审核页打不开 / 还是上一批 | 请他在文件夹里双击 `review.html`；已经开着的按 F5 刷新。 |
| `review.html` 里提示"图片没找到" | 检查 `review_data.js` 里的路径是否相对于工作区根目录、用正斜杠、文件确实在 `candidates/` 里。 |
| 压缩 zip 失败 | 检查 `outbox/` 是否存在、zip 是否被别的程序占用；换个文件名再压一次。 |
