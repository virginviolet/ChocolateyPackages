$ErrorActionPreference = 'Stop'
# chocolatey-misc-helpers.extension v0.0.4 (08-24-2020) by Bill Curran - public domain
# Runs a background job to kill $ProcessName within 5 minutes
# You would typically run this before Install-ChocolateyPackage

function Start-WaitAndStop {
    param (
        # Parameter help description
        [Parameter(mandatory = $true)][string]$ProcessName,
        [Parameter(mandatory = $false)][int]$Seconds = 290,
        [Parameter(mandatory = $false)][int]$Interval = 3
    )
    Write-Debug "Start-WaitAndStop started."
    # It's not possible to send parameters to the Start-WaitAndStopActual
    # from outside its scope, so we temporarily set variables in the Env scope
    $ENV:ProcessName = $ProcessName
    $Env:Seconds = $Seconds
    $Env:Interval = $Interval
    $Env:VerbPref = $VerbosePreference
    $Env:DebugPref = $DebugPreference

    # Enforce single instance (useful when debugging)
    Get-Job -Name WaitAndStop -ea 0 | Stop-Job
    Get-Job -Name WaitAndStop -ea 0 | Remove-Job

    # Run the actual waiting and stopping in a separate job
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    Start-Job -Name WaitAndStop -InitializationScript { $StartWaitAndStopActualScriptPath = Join-Path "$Env:WorkingDirPath" -ChildPath 'Start-WaitAndStopActual.ps1'; . "$StartWaitAndStopActualScriptPath" } `
        -ScriptBlock { Start-WaitAndStopActual } `
        > $null
    # Short pause to ensure the other script has had the time start start and
    # grab the environment variables, before we remove the environment variables
    Start-Sleep 1
    # Remove the environment variables
    Remove-Item Env:\ProcessName
    Remove-Item Env:\Seconds
    Remove-Item Env:\Interval
    Remove-Item Env:\VerbPref
    Remove-Item Env:\DebugPref
}

###### Debug start
# $VerbosePreference = 'Continue'
# $DebugPreference = 'Continue'
Start-WaitAndStop "notepad++" -Seconds 6

<#
# Let's imitate installation or something.
# Report every second what's happened in Start-WaitAndStopActual since last last report
Write-Verbose "Report test."
$Loop = 1
Do {
    Receive-WaitAndStop
    Start-Sleep 1
    Write-Host "..."
    $Loop++
}
Until ($Loop -gt 10) {
} #>

Write-Verbose "Let's write report."
$currentPath = (Get-Location).Path
$ReceiveWaitAndStopScriptPath = Join-Path $currentPath -ChildPath 'Receive-WaitAndStop.ps1'
. "$ReceiveWaitAndStopScriptPath"
# Write report when it's finished (prevents further actions in the meanwhile)
Receive-WaitAndStop -Wait
Write-Debug "Finished."