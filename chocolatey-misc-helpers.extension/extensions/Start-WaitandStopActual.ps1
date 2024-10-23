$ErrorActionPreference = 'Stop'
# $VerbosePreference = 'Continue'
# $debugPreference = 'Continue'
$VerbosePreference = $Env:VerbPref
$DebugPreference = $Env:DebugPref
function Test-Variable($Variable, $VariableName, $LogLevelInt, $LogPath) {
  if ($LogLevel -ge 4 -and $null -ne $Variable) {
    Write-Debug "Variable '$VariableName' not found!"
    Write-Output "Variable '$VariableName' not found!" >> $LogPath
  } else {
    Write-Debug "Variable '$VariableName' found."
    Write-Output "Variable '$VariableName' found." >> $LogPath
  }
}

function Start-WaitAndStopActual {
  Write-Debug "Start-WaitAndStopActual started."
  $ProcessName = $Env:ProcessName
  $Seconds = $Env:Seconds
  $Interval = $Env:Interval
  $LogLevelInt = $Env:LogLevelInt
  $LogPath = $Env:WaitAndStopLogPath
  Test-Variable $Env:VerbPref '$Env:VerbPref' $LogLevelInt $LogPath
  Test-Variable $Env:DebugPref '$Env:DebugPref' $LogLevelInt $LogPath
  Test-Variable $ProcessName '$ProcessName' $LogLevelInt $LogPath
  Test-Variable $Seconds '$Seconds' $LogLevelInt $LogPath
  Test-Variable $Interval '$Interval' $LogLevelInt $LogPath
  $maxLoops = [int]$($Seconds / $Interval)
  if ($maxLoops -le 1) {
    $maxLoops = 1
  }

  Set-Location $Env:WorkingDirPath
  # $ProcessName = "notepad++"
  # $ProcessName = "$Env:ProcessName"
  # echo "Process name: $ProcessName"
  # Write-Debug "ReportPath: $LogPath"
  Write-Debug "Looking for '$ProcessName' process..."
  Write-Output "Looking for '$ProcessName' process..." >> $LogPath
  
  $loopCount = 0
  Do {
    Write-Debug "Looping..."
    Start-Sleep 5
    try {
      Write-Debug "Looking for process..."
      Get-Process "$ProcessName" > $null
      if ($LogLevelInt -ge 1) {
        Write-Output "Stopping '$ProcessName' process..." >> $LogPath
      }
      if ($LogLevelInt -ge 4) {
        Write-Output "Process '$ProcessName' stopped." >> $LogPath
      }
      # Write-Verbose "  ** Stopping '$ProcessName' process..."
      # Write-Debug "  ** Stopping '$ProcessName' process..."
      Stop-Process -ProcessName "$ProcessName" -Force > $null
      # Write-Debug "  ** Process '$ProcessName' stopped."
      break
    } catch {}
    $loopCount++
  }
  Until ($loopCount -eq $maxLoops)

  # Write-Verbose ENDING
  if ($LogLevelInt -ge 2) {
    Write-Output "Process '$ProcessName' not found." >> $LogPath
  }
}

<# 
###### Debug start

$VerbosePreference = 'Continue'
$debugPreference = 'Continue'
$Env:Seconds = 6
$Env:ProcessName = "notepad++"
$Env:Interval = 3
$Env:WorkingDirPath = (Get-Location).Path
$Env:WaitAndStopLogPath = Join-Path $Env:WorkingDirPath "WaitAndStop.log"
Start-WaitAndStopActual

Write-Verbose "Let's write report."
$WriteWaitAndStopLogScriptPath = Join-Path $Env:WorkingDirPath -ChildPath 'Write-WaitAndStopLog.ps1'
. "$WriteWaitAndStopLogScriptPath"
Write-WaitAndStopLog #>

  
