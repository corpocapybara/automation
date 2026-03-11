try {
    Write-Host "Stopping docker containers"
    $containers = docker ps -q
    if ($containers) {
        docker stop $containers
    }
    else {
        Write-Host "No running containers found"
    }

    Write-Host "Removing docker containers"
    $allContainers = docker ps -aq
    if ($allContainers) {
        docker rm -f $allContainers
    }
    else {
        Write-Host "No containers to remove"
    }

    Write-Host "Pruning docker system"
    docker system prune -a --volumes -f

    Start-Sleep -Seconds 1

    docker system prune -a --volumes -f

    Start-Sleep -Seconds 1

    Write-Host "Removing docker volumes"
    $volumes = docker volume ls -q
    if ($volumes) {
        docker volume rm $volumes
    }
    else {
        Write-Host "No volumes to remove"
    }

    Write-Host "Recreate docker containers";
    $proc = Start-Process powershell  `
        -ArgumentList "-File", "$PSScriptRoot\start-docker.ps1" `
        -PassThru

    & "$PSScriptRoot\db-reset.ps1" -ProcessId $proc.Id
}
catch {
    Write-Error $_
    Write-Host ""
    Write-Host "An error occurred. Press Enter to close..."
    Read-Host
    exit 1
}