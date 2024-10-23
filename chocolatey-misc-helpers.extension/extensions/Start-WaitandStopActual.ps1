$ErrorActionPreference = 'Stop'
$VerbosePreference = $Env:VerbPref
$DebugPreference = $Env:DebugPref

function Test-Variable($Variable, $VariableName) {
  if ($null -ne $Variable) {
    Write-Debug "Variable '$VariableName' found."
  } else {
    Write-Debug "Variable '$VariableName' not found!"
  }
}

function Start-WaitAndStopActual {
  Write-Debug "Start-WaitAndStopActual started."
  # Variables set in Start-WaitAndStop
  $ProcessName = $Env:ProcessName
  $Seconds = $Env:Seconds
  $Interval = $Env:Interval
  # Check if the variables have been est
  Test-Variable $Env:VerbPref '$Env:VerbPref'
  Test-Variable $Env:DebugPref '$Env:DebugPref'
  Test-Variable $ProcessName '$ProcessName'
  Test-Variable $Seconds '$Seconds'
  Test-Variable $Interval '$Interval'
  $processFound = $false
  # Calculate how many loops to make
  $maxLoops = [int]$($Seconds / $Interval)
  # Enforce a positive number
  if ($maxLoops -le 1) {
    $maxLoops = 1
  }

  Write-Debug "Looking for '$ProcessName' process..."
  
  # Look for the processes in a loop with pauses
  $loopCount = 0
  Do {
    Write-Debug "Looking..."
    Start-Sleep $Interval
    try {
      Get-Process "$ProcessName" > $null
      Write-Debug "Stopping '$ProcessName' process..."
      Stop-Process -ProcessName "$ProcessName" -Force > $null
      Write-Output "Stopped '$ProcessName' process ."
      $processFound = $true
      break
    } catch {}
    $loopCount++
  }
  Until ($loopCount -eq $maxLoops)

  # Write-Verbose ENDING
  if ($processFound -eq $false) {
    Write-Debug "Search timed out.`nProcess '$ProcessName' not found."
  } 
}

###### Debug start
<# $VerbosePreference = 'Continue'
$debugPreference = 'Continue'
$Env:Seconds = 6
$Env:ProcessName = "notepad++"
$Env:Interval = 3
$Env:WorkingDirPath = (Get-Location).Path
Start-WaitAndStopActual #>
