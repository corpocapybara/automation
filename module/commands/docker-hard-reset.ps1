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
$proc = Start-Process powershell -ArgumentList "-File", "start-docker.ps1" -PassThru

Write-Host "Pull newest changes";
$oldDir = $pwd;
cd c:\dev\thp\thunderpick
git pull

Write-Host "Waiting for docker compose";
$proc.WaitForExit();

dotnet ef database drop --force --project Thunderpick.Data --startup-project Thunderpick.Api
dotnet ef database update --verbose --project Thunderpick.Data --startup-project Thunderpick.Api

cd $oldDir;