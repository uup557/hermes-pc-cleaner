---
name: pc-cleaner
version: 1.0.0
author: win二帆
platforms: [windows]
---

# PC Cleaner — Hermes Safe Cleanup Skill

Safe file cleanup for non-technical Windows users.

## Safety Rules (NEVER BREAK)

1. Scan first, never delete directly
2. Must get user confirmation before any cleanup
3. Move files to backup dir, never permanent delete
4. Exclude: C:\Windows, C:\Program Files, Desktop, Documents, Pictures, Videos
5. Log every operation
6. Report in simple Chinese

## First Run

Run install script to download tools:

```powershell
powershell -ExecutionPolicy Bypass -File ~/.hermes/skills/pc-cleaner/scripts/install.ps1
```

## Commands

### Disk overview
```powershell
dust -d 2 "C:\Users\$env:USERNAME" --reverse
```

### Find duplicates
```powershell
czkawka_cli dup -d "C:\Users\$env:USERNAME" -m 25 -s hash -f results_dup.txt
```

### Find big files
```powershell
czkawka_cli big -d "C:\Users\$env:USERNAME" -n 20 -f results_big.txt
```

### Find empty files/folders
```powershell
czkawka_cli empty-files -d "C:\Users\$env:USERNAME" -f results_empty.txt
czkawka_cli empty-folders -d "C:\Users\$env:USERNAME" -f results_folders.txt
```

### Find temp files
```powershell
czkawka_cli temp -d "C:\Users\$env:USERNAME" -f results_temp.txt
```

### Cleanup (AFTER user confirms)

Always move to backup first:

```powershell
$backupDir = "$env:USERPROFILE\.hermes\backups\pc-cleaner\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
Move-Item "C:\path\to\file" $backupDir -Force
```

## Report Template

```
📊 电脑清理报告
━━━━━━━━━━━━━━━━━━━━━━━━

💾 磁盘使用：
  C盘: 已用 XX GB / 总共 XX GB (XX%)

🔍 发现问题：
  📁 重复文件: XX 组，共 XX GB
  📁 大文件 (>100MB): XX 个，共 XX GB
  📁 空文件夹: XX 个
  📁 临时文件: XX 个，共 XX GB

✅ 建议操作：
  1. 清理重复文件 → 可释放 XX GB
  2. 清理临时文件 → 可释放 XX GB

⚠️ 安全保证：
  - 所有文件先备份，不会直接删除
  - 你可以随时恢复

要我开始清理吗？
```

## Excluded Directories

```
C:\Windows
C:\Program Files
C:\Program Files (x86)
Desktop
Documents
Pictures
Videos
```

## Notes

- First run downloads ~10MB of tools
- Scanning large disks takes a few minutes
- If user says "stop" or "不用了", stop immediately
- After cleanup, report how much space was freed