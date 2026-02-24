$ErrorActionPreference = "Stop"

Write-Host "Installing THP CLI..." -ForegroundColor Cyan

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$moduleSource = Join-Path $repoRoot "module"

# Detect user module base path dynamically
$userModuleBase = ($env:PSModulePath -split ";") |
    Where-Object { $_ -like "*$HOME*" } |
    Select-Object -First 1

if (-not $userModuleBase) {
    throw "Could not detect user module path."
}

$moduleDestination = Join-Path $userModuleBase "Thp"

# Create directory structure if missing
if (-not (Test-Path $userModuleBase)) {
    New-Item -ItemType Directory -Path $userModuleBase -Force | Out-Null
}

if (Test-Path $moduleDestination) {
    Remove-Item $moduleDestination -Recurse -Force
}

Copy-Item $moduleSource $moduleDestination -Recurse

Write-Host "Module installed to $moduleDestination" -ForegroundColor Green

# Ensure profile exists
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

if ((Get-Content $PROFILE -Raw) -notmatch "Import-Module Thp") {
    Add-Content $PROFILE "`nImport-Module Thp"
}

Write-Host ""
Write-Host "Done. Restart PowerShell."