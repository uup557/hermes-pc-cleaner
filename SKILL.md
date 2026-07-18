---
name: pc-cleaner
version: 2.0.0
author: win二帆
platforms: [windows]
---

# PC Cleaner v2 — 深度清理 Skill

针对长期没清理过的 Windows 电脑，提供深度清理能力。

## 安全铁律

1. **先扫描后操作** — 生成报告再动手
2. **必须用户确认** — 每次清理前等用户说"可以"
3. **可恢复** — 系统清理用 PowerShell，用户文件移到备份目录
4. **不碰关键数据** — 不删桌面文件、文档、照片、视频（除非用户明确要求）
5. **记录日志** — 所有操作记录到 ~/.hermes/logs/pc-cleaner.log

## 安装

首次运行安装脚本：

```powershell
powershell -ExecutionPolicy Bypass -File ~/.hermes/skills/pc-cleaner/scripts/install.ps1
```

## 清理分级

### Level 1: 系统垃圾（安全，可直接清理）

```powershell
# Windows 临时文件
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# Windows Update 清理
Stop-Service wuauserv
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
Start-Service wuauserv

# Windows 预取文件
Remove-Item "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue

# 回收站清空
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
```

### Level 2: 浏览器缓存（安全）

```powershell
# Chrome 缓存
Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Edge 缓存
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# Firefox 缓存
Remove-Item "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2\*" -Recurse -Force -ErrorAction SilentlyContinue
```

### Level 3: 应用缓存（安全但需确认）

```powershell
# 微信缓存（大头！）
Remove-Item "$env:APPDATA\Tencent\WeChat\All Users\*\FileStorage\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Tencent\WeChat\All Users\*\FileStorage\Video\*" -Recurse -Force -ErrorAction SilentlyContinue

# QQ 缓存
Remove-Item "$env:APPDATA\Tencent\QQ\*\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# 钉钉缓存
Remove-Item "$env:APPDATA\DingDing\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# 飞书缓存
Remove-Item "$env:APPDATA\Feishu\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Lark\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue
```

### Level 4: 系统深度清理（需确认）

```powershell
# Windows 磁盘清理（调用系统工具）
cleanmgr /sagerun:1

# Windows 旧版本备份
Remove-Item "C:\Windows\WinSxS\ManifestCache\*" -Force -ErrorAction SilentlyContinue

# DNS 缓存
ipconfig /flushdns

# Windows 错误报告
Remove-Item "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*" -Recurse -Force -ErrorAction SilentlyContinue

# 缩略图缓存
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
```

### Level 5: 大文件/重复文件清理（需逐项确认）

```powershell
# 用 czkawka 扫描
czkawka_cli dup -d "C:\Users\$env:USERNAME" -m 25 -s hash -f results_dup.txt
czkawka_cli big -d "C:\Users\$env:USERNAME" -n 30 -f results_big.txt
czkawka_cli empty-folders -d "C:\Users\$env:USERNAME" -f results_empty.txt
czkawka_cli temp -d "C:\Users\$env:USERNAME" -f results_temp.txt
```

## 完整清理流程

告诉 Hermes："帮我深度清理电脑"

### Step 1: 全面扫描（5-10分钟）

```powershell
# 运行扫描脚本
powershell -ExecutionPolicy Bypass -File ~/.hermes/skills/pc-cleaner/scripts/scan.ps1
```

### Step 2: 生成报告

```
📊 电脑深度清理报告
━━━━━━━━━━━━━━━━━━━━━━━━

💾 磁盘状态：
  C盘: 已用 XX GB / 总共 XX GB (XX%)
  可用空间: XX GB

🗑️ 系统垃圾（Level 1-2）：
  Windows 临时文件: XX GB
  Windows Update 缓存: XX GB
  浏览器缓存: XX GB
  回收站: XX GB
  预取文件: XX MB
  小计: XX GB — ✅ 可直接清理

📱 应用缓存（Level 3）：
  微信缓存: XX GB
  QQ 缓存: XX GB
  钉钉/飞书缓存: XX GB
  小计: XX GB — ⚠️ 需确认

🔍 重复文件（Level 5）：
  XX 组重复，共 XX GB — ⚠️ 需逐项确认

📁 大文件 TOP 10：
  1. XXXX (XX GB)
  2. XXXX (XX GB)
  ...

📁 空文件夹: XX 个

━━━━━━━━━━━━━━━━━━━━━━━━

总计可释放: XX GB

建议清理顺序：
1️⃣ 系统垃圾 → 释放 XX GB（最安全）
2️⃣ 浏览器缓存 → 释放 XX GB（安全）
3️⃣ 应用缓存 → 释放 XX GB（需确认）
4️⃣ 重复文件 → 释放 XX GB（需确认）

要我先清理哪些？说"全部"、"系统垃圾"或指定项目。
```

### Step 3: 用户确认后执行

```powershell
# 创建备份目录
$backupDir = "$env:USERPROFILE\.hermes\backups\pc-cleaner\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

# 用户文件移到备份（不是删除）
Move-Item "C:\path\to\file" $backupDir -Force

# 系统垃圾直接清理（可恢复的）
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
```

### Step 4: 完成报告

```
✅ 清理完成！

释放空间: XX GB
备份位置: ~/.hermes/backups/pc-cleaner/YYYYMMDD_HHMMSS/

如需恢复文件，从备份目录找回。
```

## 排除目录

以下目录**不扫描不清理**（除非用户明确要求）：

```
C:\Windows
C:\Program Files
C:\Program Files (x86)
Desktop
Documents
Pictures
Videos
Downloads（扫描但不自动清理）
```

## 注意事项

- 扫描大硬盘需要 5-10 分钟，告诉用户"正在扫描，稍等"
- 用户说"停"立即停止
- 微信/QQ 缓存可能很大（几 GB 到几十 GB），清理后重启应用即可
- 清理浏览器缓存后需要重新登录网站
- 不要一次清理太多，分批进行
