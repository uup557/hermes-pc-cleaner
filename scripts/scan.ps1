# scan.ps1 — Deep scan for PC cleanup

$ErrorActionPreference = "SilentlyContinue"
$toolsDir = "$env:USERPROFILE\.hermes\tools"
$resultDir = "$env:USERPROFILE\.hermes\logs\pc-cleaner-scan"
$userDir = "C:\Users\$env:USERNAME"

New-Item -ItemType Directory -Force -Path $resultDir | Out-Null

function Get-FolderSize {
    param([string]$Path)
    if (Test-Path $Path) {
        $size = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        return [math]::Round($size / 1MB, 1)
    }
    return 0
}

Write-Host "PC Cleaner Deep Scan" -ForegroundColor Cyan
Write-Host ""

# 1. Disk
Write-Host "[1/6] Disk..." -ForegroundColor Yellow
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$totalGB = [math]::Round($disk.Size / 1GB, 1)
$freeGB = [math]::Round($disk.FreeSpace / 1GB, 1)
$usedGB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 1)
$usedPct = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 0)
Write-Host "  C: $usedGB GB / $totalGB GB ($usedPct% used, $freeGB GB free)"

# 2. System junk
Write-Host "[2/6] System junk..." -ForegroundColor Yellow
$tempSize = Get-FolderSize "$env:TEMP"
$winTempSize = Get-FolderSize "C:\Windows\Temp"
$prefetchSize = Get-FolderSize "C:\Windows\Prefetch"
$wuSize = Get-FolderSize "C:\Windows\SoftwareDistribution\Download"
$werSize = Get-FolderSize "C:\ProgramData\Microsoft\Windows\WER"
$thumbsSize = Get-FolderSize "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
Write-Host "  Temp: $tempSize MB | WinTemp: $winTempSize MB | Prefetch: $prefetchSize MB"
Write-Host "  WinUpdate: $wuSize MB | ErrorReports: $werSize MB | Thumbs: $thumbsSize MB"

# 3. Browser cache
Write-Host "[3/6] Browser cache..." -ForegroundColor Yellow
$chromeCache = Get-FolderSize "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
$chromeCode = Get-FolderSize "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache"
$edgeCache = Get-FolderSize "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
$edgeCode = Get-FolderSize "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache"
$firefoxCache = Get-FolderSize "$env:LOCALAPPDATA\Mozilla\Firefox"
Write-Host "  Chrome: $chromeCache MB + $chromeCode MB"
Write-Host "  Edge: $edgeCache MB + $edgeCode MB"
Write-Host "  Firefox: $firefoxCache MB"

# 4. App cache
Write-Host "[4/6] App cache..." -ForegroundColor Yellow
$wechatCache = Get-FolderSize "$env:APPDATA\Tencent\WeChat"
$qqCache = Get-FolderSize "$env:APPDATA\Tencent\QQ"
$dingtalkCache = Get-FolderSize "$env:APPDATA\DingDing"
$feishuCache = Get-FolderSize "$env:APPDATA\Feishu"
$larkCache = Get-FolderSize "$env:APPDATA\Lark"
Write-Host "  WeChat: $wechatCache MB | QQ: $qqCache MB"
Write-Host "  DingTalk: $dingtalkCache MB | Feishu: $feishuCache MB | Lark: $larkCache MB"

# 5. Recycle bin
Write-Host "[5/6] Recycle bin..." -ForegroundColor Yellow
$shell = New-Object -ComObject Shell.Application
$rb = $shell.Namespace(0xA)
$count = 0; $rb.Items() | ForEach-Object { $count++ }
Write-Host "  Items: $count"

# 6. Duplicates
Write-Host "[6/6] Duplicates & big files..." -ForegroundColor Yellow
if (Test-Path "$toolsDir\czkawka_cli.exe") {
    & "$toolsDir\czkawka_cli.exe" dup -d $userDir -m 25 -s hash -f "$resultDir\duplicates.txt" 2>&1 | Out-Null
    & "$toolsDir\czkawka_cli.exe" big -d $userDir -n 30 -f "$resultDir\bigfiles.txt" 2>&1 | Out-Null
    & "$toolsDir\czkawka_cli.exe" empty-folders -d $userDir -f "$resultDir\emptyfolders.txt" 2>&1 | Out-Null
    Write-Host "  Results saved to $resultDir" -ForegroundColor Green
} else {
    Write-Host "  czkawka not found, skipping" -ForegroundColor Red
}

Write-Host ""
Write-Host "Top folders:" -ForegroundColor Cyan
if (Test-Path "$toolsDir\dust.exe") {
    & "$toolsDir\dust.exe" -d 2 $userDir --reverse 2>&1
}

Write-Host "Scan complete!" -ForegroundColor Green
