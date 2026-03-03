function start-docker-4-win {
    docker ps *> $null
    if(!($?)) {
        write-host 'Starting docker...'
        C:\'Program Files'\Docker\Docker\'Docker Desktop.exe'

        $counter = 20;
        while ($true) {
            docker ps *> $null
            if ($?) {
                break;
            }
            $counter--;
            
            if ($counter -le 0) {
                break;
            }
            Start-Sleep -Seconds 1
            Write-Host '.'
        }
        
        return ($counter -gt 0);
    }
    
    return $true;
}

try {
    start-docker-4-win;

    Write-Host "Stopping docker";
    docker stop $(docker ps -q)
    Write-Host "Removing docker images";
    docker rm -f $(docker ps -aq)

    Write-Host "Removing docker volumes";
    docker system prune -a --volumes -f

    sleep(1);

    docker system prune -a --volumes -f

    sleep(1);

    docker volume rm $(docker volume ls -q)


    Write-Host "Recreate docker containers";
    $proc = Start-Process powershell  `
        -ArgumentList "-File", "$PSScriptRoot\start-docker.ps1" `
        -PassThru

    Write-Host "Pull newest changes";
    $oldDir = $pwd;
    cd c:\dev\thp\thunderpick
    git pull


    # Step 1: Get required SDK version from global.json
    if (!(Test-Path "global.json")) {
        Write-Host "No global.json found. Running dotnet ef directly..."
        dotnet ef @args
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

    Write-Host "Waiting for docker compose";
    $proc.WaitForExit();

    dotnet ef database drop --force --project Thunderpick.Data --startup-project Thunderpick.Api
    dotnet ef database update --verbose --project Thunderpick.Data --startup-project Thunderpick.Api

    cd $oldDir;
}
catch {
    Write-Error $_
    Write-Host ""
    Write-Host "An error occurred. Press Enter to close..."
    Read-Host
    exit 1
}