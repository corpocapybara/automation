param(
    [int]$ProcessId
)

Write-Host "Pull newest changes";
$oldDir = $pwd;
cd c:\dev\thp\thunderpick
git pull

if (!(Test-Path "global.json")) {
    Write-Host "No global.json found. Running dotnet ef directly..."
} else {
    $globalJson = Get-Content "global.json" | ConvertFrom-Json
    $requiredVersion = $globalJson.sdk.version

    Write-Host "Required SDK version: $requiredVersion"
    $installDir = "$env:USERPROFILE\.dotnet"
    $env:PATH = "$installDir;$env:PATH"
    
    # Step 2: Check installed SDKs
    $installedSdks = dotnet --list-sdks | ForEach-Object {
        ($_ -split '\s+')[0]
    }

    if ($installedSdks -contains $requiredVersion) {
        Write-Host "SDK $requiredVersion is already installed."
    }
    else {
        Write-Host "SDK $requiredVersion NOT installed. Installing..."
        Get-Process dotnet -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "Stopping dotnet process Id=$($_.Id)"
            Stop-Process -Id $_.Id -Force
        }

        Start-Sleep -Seconds 2

        # Download dotnet-install.ps1 if not exists
        if (!(Test-Path ".\dotnet-install.ps1")) {
            Invoke-WebRequest `
                -Uri https://dot.net/v1/dotnet-install.ps1 `
                -OutFile dotnet-install.ps1
        }

        .\dotnet-install.ps1 `
            -Version $requiredVersion `
            -InstallDir $installDir

        # Install required SDK
        .\dotnet-install.ps1 -Version $requiredVersion -InstallDir $installDir

        Write-Host "Installation completed."
    }
}

if ($ProcessId) {
    $proc = Get-Process -Id $ProcessId
    Write-Host "Waiting for docker compose";
    $proc.WaitForExit();
}

dotnet ef database drop --force --project Thunderpick.Data --startup-project Thunderpick.Api
dotnet ef database update --verbose --project Thunderpick.Data --startup-project Thunderpick.Api

cd $oldDir;