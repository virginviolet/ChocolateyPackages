$ErrorActionPreference = 'Stop'
# chocolatey-misc-helpers.extension v0.0.4 (08-24-2020) by Bill Curran - public domain
# Runs a background job to kill $ProcessName within 5 minutes
# You would typically run this before Install-ChocolateyPackage

function Start-WaitAndStop {
    param (
        # Parameter help description
        [Parameter(mandatory = $true)][string]$ProcessName,
        [Parameter(mandatory = $false)][int]$Seconds = 300,
        [Parameter(mandatory = $false)][int]$Interval = 3
    )
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
    Write-Warning "Waiting to stop '$ProcessName'..."
    Start-Job -Name WaitAndStop -InitializationScript { . "$ENV:ChocolateyInstall\extensions\chocolatey-misc-helpers\Start-WaitAndStopActual.ps1" } `
        -ScriptBlock { Start-WaitAndStopActual } `
        > $null
    
    # Remove the environment variables
    # Short pause to ensure the other script has had the time start start and
    # grab the environment variables
    Start-Sleep 1
    Remove-Item Env:\ProcessName
    Remove-Item Env:\Seconds
    Remove-Item Env:\Interval
    Remove-Item Env:\VerbPref
    Remove-Item Env:\DebugPref
}
