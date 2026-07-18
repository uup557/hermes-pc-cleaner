# scan.ps1 — PC Cleaner scanning script
# Scans user directory and generates a cleanup report

$ErrorActionPreference = "Stop"
$toolsDir = "$env:USERPROFILE\.hermes\tools"
$userDir = "C:\Users\$env:USERNAME"
$resultDir = "$env:USERPROFILE\.hermes\logs\pc-cleaner-scan"
$logFile = "$env:USERPROFILE\.hermes\logs\pc-cleaner.log"

New-Item -ItemType Directory -Force -Path $resultDir | Out-Null

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logFile
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PC Cleaner - Scanning your PC..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Disk usage overview
Write-Host "[1/4] Checking disk usage..." -ForegroundColor Yellow
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$totalGB = [math]::Round($disk.Size / 1GB, 1)
$freeGB = [math]::Round($disk.FreeSpace / 1GB, 1)
$usedGB = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 1)
$usedPct = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 0)

Write-Host ""
Write-Host "Disk C: $usedGB GB used / $totalGB GB total ($usedPct%)" -ForegroundColor White
Write-Host ""

# 2. Find duplicates
Write-Host "[2/4] Finding duplicate files..." -ForegroundColor Yellow
$dupResult = & "$toolsDir\czkawka_cli.exe" dup -d $userDir -m 25 -s hash -f "$resultDir\duplicates.txt" 2>&1
Write-Host "  Results saved to: $resultDir\duplicates.txt"

# 3. Find big files
Write-Host "[3/4] Finding large files..." -ForegroundColor Yellow
$bigResult = & "$toolsDir\czkawka_cli.exe" big -d $userDir -n 20 -f "$resultDir\bigfiles.txt" 2>&1
Write-Host "  Results saved to: $resultDir\bigfiles.txt"

# 4. Find empty files and folders
Write-Host "[4/4] Finding empty files and folders..." -ForegroundColor Yellow
& "$toolsDir\czkawka_cli.exe" empty-files -d $userDir -f "$resultDir\emptyfiles.txt" 2>&1 | Out-Null
& "$toolsDir\czkawka_cli.exe" empty-folders -d $userDir -f "$resultDir\emptyfolders.txt" 2>&1 | Out-Null
Write-Host "  Results saved to: $resultDir\emptyfiles.txt"
Write-Host "  Results saved to: $resultDir\emptyfolders.txt"

# 5. Top disk usage with dust
Write-Host ""
Write-Host "Top folders by size:" -ForegroundColor Cyan
& "$toolsDir\dust.exe" -d 2 $userDir --reverse 2>&1

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Scan complete!" -ForegroundColor Green
Write-Host "  Results: $resultDir" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Read the report files to see what can be cleaned." -ForegroundColor Gray
Write-Host "Always confirm with user before deleting anything." -ForegroundColor Gray