$Script:ThpRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:CommandsPath = Join-Path $Script:ThpRoot "commands"

function Get-ThpCommands {
    Get-ChildItem -Path $Script:CommandsPath -Filter "*.ps1" |
        Select-Object -ExpandProperty BaseName
}

function thp {
    param(
        [Parameter(Position=0)]
        [string]$Command,

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Args
    )

    if (-not $Command -or $Command -eq "help") {
        Write-Host ""
        Write-Host "THP CLI"
        Write-Host "Available commands:"
        Get-ThpCommands | ForEach-Object {
            Write-Host "  - $_"
        }
        Write-Host ""
        return
    }

    $commandFile = Join-Path $Script:CommandsPath "$Command.ps1"

    if (-not (Test-Path $commandFile)) {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        return
    }

    & $commandFile @Args
}

# Autocomplete
Register-ArgumentCompleter -CommandName thp -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)

    Get-ThpCommands |
        Where-Object { $_ -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}

Export-ModuleMember -Function thp