# install.ps1 — PC Cleaner tool installer
# Downloads czkawka_cli and dust to ~/.hermes/tools/

$ErrorActionPreference = "Stop"
$toolsDir = "$env:USERPROFILE\.hermes\tools"
$logFile = "$env:USERPROFILE\.hermes\logs\pc-cleaner.log"

# Create directories
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.hermes\logs" | Out-Null
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.hermes\backups\pc-cleaner" | Out-Null

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logFile
    Write-Host $Message
}

function Download-IfMissing {
    param(
        [string]$Name,
        [string]$Url,
        [string]$OutPath
    )
    if (Test-Path $OutPath) {
        Write-Log "  [OK] $Name already installed"
        return
    }
    Write-Log "  Downloading $Name ..."
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutPath -UseBasicParsing
        Write-Log "  [OK] $Name installed"
    } catch {
        Write-Log "  [FAIL] $Name download failed: $_"
        Write-Log "    Manual download: $Url"
    }
}

Write-Log "=== PC Cleaner Tool Installer ==="

# 1. czkawka_cli
$czkawkaUrl = "https://github.com/qarmin/czkawka/releases/latest/download/czkawka_cli.exe"
Download-IfMissing -Name "czkawka_cli" -Url $czkawkaUrl -OutPath "$toolsDir\czkawka_cli.exe"

# 2. dust
$zipPath = "$toolsDir\dust.zip"
$dustUrl = "https://github.com/bootandy/dust/releases/latest/download/dust-v0.8.6-x86_64-pc-windows-msvc.zip"
Download-IfMissing -Name "dust" -Url $dustUrl -OutPath $zipPath

if ((Test-Path $zipPath) -and !(Test-Path "$toolsDir\dust.exe")) {
    Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force
    $dustExe = Get-ChildItem -Path $toolsDir -Recurse -Filter "dust.exe" | Select-Object -First 1
    if ($dustExe) {
        Move-Item $dustExe.FullName "$toolsDir\dust.exe" -Force
    }
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    Write-Log "  [OK] dust extracted"
}

# 3. Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$toolsDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$toolsDir", "User")
    $env:Path = "$env:Path;$toolsDir"
    Write-Log "  [OK] Added tools to PATH"
}

# 4. Verify
Write-Log ""
Write-Log "Verification:"
$czkawkaOk = Test-Path "$toolsDir\czkawka_cli.exe"
$dustOk = Test-Path "$toolsDir\dust.exe"
Write-Log "  czkawka_cli: $(if ($czkawkaOk) {'OK'} else {'MISSING'})"
Write-Log "  dust:        $(if ($dustOk) {'OK'} else {'MISSING'})"
Write-Log ""
Write-Log "Done! Ready to clean PC."