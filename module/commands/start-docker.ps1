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

cd C:\dev\thp\thunderpick\dev-setup\docker-compose-stacks\infrastructure-stacks
docker compose up -d
cd ..\static-stack
docker compose up -d
docker stop thp-nginx
docker stop thp-api
docker start thp-nginx