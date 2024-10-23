$ErrorActionPreference = 'Stop'
# chocolatey-misc-helpers.extension v0.0.4 (08-24-2020) by Bill Curran - public domain
# Runs a background job to kill $ProcessName within 5 minutes
# You would typically run this before Install-ChocolateyPackage
$VerbosePreference = 'Continue'
$debugPreference = 'Continue'

function ConvertTo-LogLevelInt($LogLevelLabel) {
    if ($LogLevelLabel -eq [MiscHelpers_LogLevel]::None) {
        $LogLevelInt = 0
    } elseif ($LogLevelLabel -eq [MiscHelpers_LogLevel]::Success) {
        $LogLevelInt = 1
    } elseif ($LogLevelLabel -eq [MiscHelpers_LogLevel]::Error) {
        $LogLevelInt = 2
    } elseif ($LogLevelLabel -eq [MiscHelpers_LogLevel]::Warning) {
        $LogLevelInt = 3
    } elseif ($LogLevelLabel -eq [MiscHelpers_LogLevel]::Verbose) {
        $LogLevelInt = 4
    } elseif ($LogLevelLabel -eq [MiscHelpers_LogLevel]::Debug) {
        $LogLevelInt = 5
    }
    return $LogLevelInt
}

function Start-WaitAndStop {
    param (
        # Parameter help description
        [Parameter(mandatory = $true)][string]$ProcessName,
        [Parameter(mandatory = $false)][int]$Seconds = 290,
        [Parameter(mandatory = $false)][int]$Interval = 3,
        [Parameter(mandatory = $false)][MiscHelpers_LogLevel]$LogLevel = [MiscHelpers_LogLevel]::None
    )
    Write-Debug "Start-WaitAndStop started."
    $ENV:ProcessName = $ProcessName
    $Env:Seconds = $Seconds
    $Env:Interval = $Interval
    $Env:VerbPref = $VerbosePreference
    $Env:DebugPref = $DebugPreference
    $currentPath = (Get-Location).Path
    $Env:WorkingDirPath = $currentPath
    $LogLevelInt = ConvertTo-LogLevelInt $LogLevel
    $Env:LogLevelInt = $LogLevelInt
    $Env:WaitAndStopLogPath = Join-Path $currentPath "WaitAndStop.log"
    Write-Debug "WaitAndStop log file path: '$Env:WaitAndStopLogPath'"

    # Enforce single job
    Get-Job -Name WaitAndStop -ea 0 | Stop-Job
    Get-Job -Name WaitAndStop -ea 0 | Remove-Job

    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    Start-Job -Name WaitAndStop -InitializationScript { $StartWaitAndStopActualScriptPath = Join-Path "$Env:WorkingDirPath" -ChildPath 'Start-WaitAndStopActual.ps1'; . "$StartWaitAndStopActualScriptPath" } `
        -ScriptBlock { Start-WaitAndStopActual } `
        > $null
    # Write-Host "Sleeping parent"
    # Start-Sleep 10
    # Receive-Job -Name WaitAndStop
    # Receive-Job -Name WaitAndStop -Wait -WriteEvents > $null
    Remove-Item Env:\ProcessName
    Remove-Item Env:\Seconds
    Remove-Item Env:\Interval
    Remove-Item Env:\WaitAndStopLogPath
}

###### Debug start

enum MiscHelpers_LogLevel {
    None
    Success
    Error
    Warning
    Verbose
    Debug
}


Start-WaitAndStop "notepad++" -Seconds 3 -LogLevel Debug
Start-Sleep 6
Write-Verbose "Let's write report."
$currentPath = (Get-Location).Path
$WriteWaitAndStopLogScriptPath = Join-Path $currentPath -ChildPath 'Write-WaitAndStopLog.ps1'
. "$WriteWaitAndStopLogScriptPath"
# Write-WaitAndStopLog | Write-Verbose
Write-WaitAndStopLog

<# $Loop = 1
Do {
    Write-Host ...
    Start-Sleep 3
    Receive-Job -Name ActualJob
    $Loop++
}
Until ($Loop -gt 60) {
} #>