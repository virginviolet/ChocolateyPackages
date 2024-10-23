$ErrorActionPreference = 'Stop'
$VerbosePreference = $Env:VerbPref
$DebugPreference = $Env:DebugPref

function Start-WaitAndStopActual {
  Write-Debug "Start-WaitAndStopActual started."
  # Variables set in Start-WaitAndStop
  $ProcessName = $Env:ProcessName
  $Seconds = $Env:Seconds
  $Interval = $Env:Interval
  # Check if the variables have been est
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

  if ($processFound -eq $false) {
    Write-Debug "Search timed out.`nProcess '$ProcessName' not found."
  } 
}
