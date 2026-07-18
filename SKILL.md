---
name: pc-cleaner
version: 2.0.0
author: win二帆
platforms: [windows]
---

# PC Cleaner v2 — Deep Cleaning Skill

针对长期没清理过的 Windows 电脑，提供深度清理能力。

## 安全铁律

1. **先扫描后操作** — 生成报告再动手
2. **必须用户确认** — 每次清理前等用户说"可以"
3. **可恢复** — 系统清理用 PowerShell，用户文件移到备份目录
4. **不碰关键数据** — 不删桌面文件、文档、照片、视频
5. **记录日志** — 所有操作记录

## 安装

```powershell
powershell -ExecutionPolicy Bypass -File ~/.hermes/skills/pc-cleaner/scripts/install.ps1
```

## 清理分级

### Level 1: 系统垃圾（安全，可直接清理）

```powershell
# Windows 临时文件
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
# Windows Update 缓存
Stop-Service wuauserv
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
Start-Service wuauserv
# 预取文件
Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
# 回收站
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
```

### Level 2: 浏览器缓存（安全）

```powershell
# Chrome
Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
# Edge
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
# Firefox
Remove-Item "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2\*" -Recurse -Force -ErrorAction SilentlyContinue
```

### Level 3: 应用缓存（需确认）

```powershell
# 微信缓存（大头！）
Remove-Item "$env:APPDATA\Tencent\WeChat\All Users\*\FileStorage\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Tencent\WeChat\All Users\*\FileStorage\Video\*" -Recurse -Force -ErrorAction SilentlyContinue
# QQ
Remove-Item "$env:APPDATA\Tencent\QQ\*\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
# 钉钉
Remove-Item "$env:APPDATA\DingDing\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
# 飞书
Remove-Item "$env:APPDATA\Feishu\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Lark\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
```

### Level 4: 系统深度清理（需确认）

```powershell
# DNS 缓存
ipconfig /flushdns
# Windows 错误报告
Remove-Item "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue
# 缩略图缓存
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
```

### Level 5: 重复/大文件（逐项确认）

```powershell
czkawka_cli dup -d "C:\Users\$env:USERNAME" -m 25 -s hash -f results_dup.txt
czkawka_cli big -d "C:\Users\$env:USERNAME" -n 30 -f results_big.txt
czkawka_cli empty-folders -d "C:\Users\$env:USERNAME" -f results_empty.txt
czkawka_cli temp -d "C:\Users\$env:USERNAME" -f results_temp.txt
```

## 清理流程

1. 扫描：`powershell -ExecutionPolicy Bypass -File scripts/scan.ps1`
2. 报告：生成中文清理报告
3. 确认：等用户批准
4. 执行：系统垃圾直接清，用户文件移到备份目录
5. 完成：报告释放了多少空间

## 排除目录

```
C:\Windows, C:\Program Files, C:\Program Files (x86)
Desktop, Documents, Pictures, Videos
Downloads（扫描但不自动清理）
```

## 注意事项

- 微信/QQ 缓存可能几 GB 到几十 GB，清理后重启应用即可
- 浏览器缓存清理后需重新登录网站
- 用户说"停"立即停止
- 分批清理，不要一次全清
