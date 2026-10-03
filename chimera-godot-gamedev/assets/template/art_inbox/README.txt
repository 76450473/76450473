把你生成的图片放在这个文件夹里，然后对 Claude 说「导入美术」。

1. 文件名要写成资产 id，例如 part_eye_compound.png、body_biped.png、bg_swamp.png。
   所有资产 id、对应的提示词、比例和背景要求，都在 docs/ART_TODO.md（缺失的）和 docs/ART_PROMPTS.md（全部）里。
   名字写错也没关系，Claude 会打开图片看是什么，再帮你改名。
2. 背景要求：灰度部件和骨架用纯白平底；图标用纯黑平底；背景图和卡图按画面正常生成。
   主体要有粗的深色描边，并且尽量占满画面。
3. 在本文件夹新建 credits.txt，写一行：你用的工具或模型，以及授权。
   例如：Midjourney v7，付费订阅可商用
4. 导入后，原图会被移到 _done/ 子文件夹；处理好的资产在 art/ 里。

png、jpg、jpeg、webp 格式都可以。缺的资产不影响游戏运行，会自动用程序画的占位图代替。
