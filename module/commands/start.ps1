$dockerProcess = Start-Process powershell -ArgumentList "-File", "start-docker.ps1" -PassThru

$oldDir = $pwd;
cd c:\dev\thp\thunderpick
git pull
cd $oldDir;

$dockerProcess.WaitForExit();

wt -w 0 new-tab -d $PSScriptRoot PowerShell -File "$PSScriptRoot\start-oddin-stack.ps1"