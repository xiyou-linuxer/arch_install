# 说明

本脚本包括 `install1.sh` 与 `install2.sh` (以下以脚本 1 与脚本 2 代替)
其中脚本 1 适用于 ArchLinux 引导系统
脚本 2 适用于安装的 ArchLinxu 新系统

## install1.sh 注意事项

1. 提前分区

本脚本假定用户使用 `GPT` 分区表，并以 `EFI` 启动 ArchLinux 安装介质。
本脚本假定用户使用 `zh-CN ` 并且使用 `UTC+8` 作为系统的视区。


- 确保拥有 `/mnt` 目录作为新系统的 `/` 根目录

- 确保拥有 `/mnt/boot` 目录作为新系统的 `/boot` 目录

其余目录（如 `/home` 与 `/swap`）可选挂载


2. 将脚本 1 与脚本 2 放置于同一目录下

3. 请避免非法输入,严格按照提示语句回复,如果没有提示则尽量回车跳过

## 使用条件

1. 分区已挂载完成

2. 将脚本 1 与脚本 2 拷至 引导系统中的同一目录下, 并授予可执行权限

3. 明确知道自己在干什么,并知道怎样查看错误输出.

4. 能主动尝试解决一般报错

5. 阅读 [提问的智慧](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/main/README-zh_CN.md) 后向本项目提交 issues
